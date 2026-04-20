#!/usr/bin/env ruby
# frozen_string_literal: true

# Flattens the sub-feature layer (features/<feature>/<subfeature>/...) into
# (features/<feature>/...) and renames service/handler/validator/helper files
# with role suffixes so they no longer collide.
#
# Usage:
#   ruby bin/flatten_subfeatures.rb --dry-run   # preview only
#   ruby bin/flatten_subfeatures.rb             # apply changes

require 'fileutils'

ROOT = File.expand_path('..', __dir__)
FEATURES_DIR = File.join(ROOT, 'features')
DRY = ARGV.include?('--dry-run')

# group dir name => class suffix (nil = keep names as-is)
GROUP_SUFFIXES = {
  'services' => 'Service',
  'handlers' => 'Handler',
  'validators' => 'Validator',
  'helpers' => 'Helper',
  'errors' => nil
}.freeze

CONTENT_DIRS = %w[views functions].freeze

def log(msg)
  puts "#{DRY ? '[dry] ' : ''}#{msg}"
end

def rel(path)
  path.sub("#{ROOT}/", '')
end

def camel(snake)
  snake.split('_').map(&:capitalize).join
end

def write(path, content)
  log "write  #{rel(path)}"
  File.write(path, content) unless DRY
end

def move(src, dst)
  log "move   #{rel(src)} -> #{rel(dst)}"
  FileUtils.mv(src, dst) unless DRY
end

def delete(path)
  log "delete #{rel(path)}"
  File.delete(path) unless DRY
end

def mkdir_p(path)
  return if Dir.exist?(path)

  log "mkdir  #{rel(path)}"
  FileUtils.mkdir_p(path) unless DRY
end

def rmdir(path)
  return unless Dir.exist?(path)
  return unless Dir.glob("#{path}/*").empty?

  log "rmdir  #{rel(path)}"
  Dir.rmdir(path) unless DRY
end

# Transforms a file defining
#   module Porotutu; module Feature; module Subfeature; module Group; class X
# into
#   module Porotutu; module Feature; class NewX
# by stripping the Subfeature and Group module wrappers and dedenting by 4.
def transform_grouped(content, new_class_name)
  lines = content.lines
  body_start = lines.index { |l| l.start_with?('module ') }
  raise 'no module line found' unless body_start

  prologue = lines[0...body_start]
  body = lines[body_start..]

  unless body[0]&.match?(/\Amodule Porotutu\b/) &&
         body[1]&.match?(/\A  module \w+\b/) &&
         body[2]&.match?(/\A    module \w+\b/) &&
         body[3]&.match?(/\A      module \w+\b/)
    raise "unexpected module structure:\n#{body[0..4].join}"
  end

  inner = body[4..-5]
  dedented = inner.map { |l| l.strip.empty? ? l : l.sub(/\A {4}/, '') }
  dedented[0] = dedented[0].sub(/class \w+/, "class #{new_class_name}")

  [
    *prologue,
    "module Porotutu\n",
    body[1],
    *dedented,
    "  end\n",
    "end\n"
  ].join
end

# Same idea for a sub-feature routes.rb, which has one fewer module level.
def transform_subfeature_routes(content, new_class_name)
  lines = content.lines
  body_start = lines.index { |l| l.start_with?('module ') }
  raise 'no module line found' unless body_start

  prologue = lines[0...body_start]
  body = lines[body_start..]

  unless body[0]&.match?(/\Amodule Porotutu\b/) &&
         body[1]&.match?(/\A  module \w+\b/) &&
         body[2]&.match?(/\A    module \w+\b/)
    raise "unexpected module structure:\n#{body[0..3].join}"
  end

  inner = body[3..-4]
  dedented = inner.map { |l| l.strip.empty? ? l : l.sub(/\A {2}/, '') }
  dedented[0] = dedented[0].sub(/class \w+/, "class #{new_class_name}")

  [
    *prologue,
    "module Porotutu\n",
    body[1],
    *dedented,
    "  end\n",
    "end\n"
  ].join
end

def process_feature(feature_dir)
  feature = File.basename(feature_dir)
  subfeature_dirs = Dir.glob("#{feature_dir}/*").select { |d| File.directory?(d) }
  subfeatures = subfeature_dirs.map { |d| File.basename(d) }
  return if subfeatures.empty?

  log ''
  log "=== #{feature} (sub-features: #{subfeatures.join(', ')}) ==="

  subfeature_dirs.each { |sd| flatten_subfeature(sd, feature_dir) }
  update_references(feature_dir, subfeatures)
end

def flatten_subfeature(subfeature_dir, feature_dir)
  subfeature = File.basename(subfeature_dir)
  subfeature_mod = camel(subfeature)

  GROUP_SUFFIXES.each do |group, suffix|
    group_dir = File.join(subfeature_dir, group)
    next unless Dir.exist?(group_dir)

    Dir.glob("#{group_dir}/*.rb").each do |src|
      base = File.basename(src, '.rb')
      new_base = suffix ? "#{base}_#{suffix.downcase}" : base
      class_name = camel(base)
      new_class = suffix ? "#{class_name}#{suffix}" : class_name

      new_group_dir = File.join(feature_dir, group)
      mkdir_p(new_group_dir)
      dst = File.join(new_group_dir, "#{new_base}.rb")

      if File.exist?(dst)
        log "SKIP   destination exists: #{rel(dst)}"
        next
      end

      content = File.read(src)
      new_content =
        begin
          transform_grouped(content, new_class)
        rescue StandardError => e
          log "ERROR  #{rel(src)}: #{e.message}"
          next
        end
      write(dst, new_content)
      delete(src)
    end

    rmdir(group_dir)
  end

  routes_src = File.join(subfeature_dir, 'routes.rb')
  if File.exist?(routes_src)
    routes_dst = File.join(feature_dir, "#{subfeature}_routes.rb")
    if File.exist?(routes_dst)
      log "SKIP   destination exists: #{rel(routes_dst)}"
    else
      new_class = "#{subfeature_mod}Routes"
      content = File.read(routes_src)
      begin
        new_content = transform_subfeature_routes(content, new_class)
        write(routes_dst, new_content)
        delete(routes_src)
      rescue StandardError => e
        log "ERROR  #{rel(routes_src)}: #{e.message}"
      end
    end
  end

  CONTENT_DIRS.each do |dir|
    src_dir = File.join(subfeature_dir, dir)
    next unless Dir.exist?(src_dir)

    dst_dir = File.join(feature_dir, dir)
    mkdir_p(dst_dir)

    Dir.glob("#{src_dir}/*").each do |file|
      dst = File.join(dst_dir, File.basename(file))
      if File.exist?(dst)
        log "SKIP   destination exists: #{rel(dst)}"
        next
      end
      move(file, dst)
    end
    rmdir(src_dir)
  end

  if Dir.exist?(subfeature_dir) && !Dir.glob("#{subfeature_dir}/*").empty?
    log "WARN   sub-feature dir not empty, leaving: #{rel(subfeature_dir)}"
  else
    rmdir(subfeature_dir)
  end
end

def update_references(feature_dir, subfeatures)
  substitutions = []

  subfeatures.each do |sf|
    mod = camel(sf)
    substitutions << [/\b#{mod}::Routes\b/, "#{mod}Routes"]
  end

  GROUP_SUFFIXES.each do |group, suffix|
    group_mod = camel(group)
    substitutions << [
      /\b#{group_mod}::(\w+)/,
      suffix ? "\\1#{suffix}" : '\\1'
    ]
  end

  Dir.glob("#{feature_dir}/**/*.rb").each do |file|
    content = File.read(file)
    new_content = content.dup
    substitutions.each { |pat, rep| new_content.gsub!(pat, rep) }
    next if new_content == content

    log "refs   #{rel(file)}"
    File.write(file, new_content) unless DRY
  end
end

Dir.glob("#{FEATURES_DIR}/*").each do |feature_dir|
  next unless File.directory?(feature_dir)

  process_feature(feature_dir)
end

log ''
log 'Done. Follow-ups:'
log '  1. Add to app.rb after `loader.collapse("#{__dir__}/features")`:'
log '     loader.collapse("#{__dir__}/features/*/{services,handlers,validators,helpers,errors}")'
log '  2. Decide what to do with each features/<feature>/routes.rb that now mounts'
log '     `use CrudRoutes` / `use AuthRoutes` (the reference rewrite already happened).'
log '  3. Update tests/ to mirror the new structure.'
log '  4. Update CLAUDE.md.'
log '  5. Run the test suite.'
