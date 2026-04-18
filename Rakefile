# frozen_string_literal: true

require 'dotenv/load'
require 'pg'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << '.'
  t.pattern = 'tests/**/*_test.rb'
end

DATABASE_URL = ENV.fetch('DATABASE_URL', 'postgres://localhost/porotutu')
DB_DIR       = File.expand_path('db', __dir__)
ROOT_DIR     = __dir__

module Color
  RESET  = "\e[0m"
  BOLD   = "\e[1m"
  RED    = "\e[31m"
  GREEN  = "\e[32m"
  YELLOW = "\e[33m"
  CYAN   = "\e[36m"
  DIM    = "\e[2m"

  def self.header(text)   = "#{BOLD}#{CYAN}#{text}#{RESET}"
  def self.success(text)  = "#{GREEN}#{text}#{RESET}"
  def self.error(text)    = "#{RED}#{text}#{RESET}"
  def self.skipped(text)  = "#{YELLOW}#{text}#{RESET}"
  def self.path(text)     = "#{DIM}#{text}#{RESET}"
  def self.label(text)    = "#{BOLD}#{text}#{RESET}"
end

def relative_path(filepath)
  filepath.delete_prefix("#{ROOT_DIR}/")
end

def with_connection
  conn = PG.connect(DATABASE_URL)
  yield conn
ensure
  conn&.finish
end

def run_sql_file(conn, filepath)
  conn.exec(File.read(filepath))
end

def print_header(title)
  puts "\n#{Color.header("--- #{title} ---")}\n\n"
end

def print_footer(message, color: :success)
  puts "\n#{Color.send(color, message)}\n"
end

def run_file(conn, filepath, rel)
  run_sql_file(conn, filepath)
  yield if block_given?
  puts "#{Color.path(rel)} #{Color.success('=> Success')}"
  :ok
rescue PG::Error => e
  puts "#{Color.path(rel)} #{Color.error('=> Error:')} #{e.message}"
  :error
end

def run_scripts_in_folder(folder)
  files = Dir["#{File.join(DB_DIR, folder)}/*.sql"]

  print_header("Running scripts in '#{folder}'")

  with_connection do |conn|
    files.each do |filepath|
      exit 1 if run_file(conn, filepath, relative_path(filepath)) == :error
    end
  end

  print_footer("Completed #{folder}")
end

def apply_migration(conn, filepath, applied)
  rel     = relative_path(filepath)
  version = File.basename(filepath).split('_').first

  if applied.include?(version)
    puts "#{Color.path(rel)} #{Color.skipped('=> Skipped (already applied)')}"
    return
  end

  record = -> { conn.exec_params('INSERT INTO schema_migrations (version) VALUES ($1)', [version]) }
  exit 1 if run_file(conn, filepath, rel, &record) == :error
end

def run_migrations
  files = Dir["#{File.join(DB_DIR, 'migrate')}/*.sql"]
  print_header("Running scripts in 'migrate'")

  with_connection do |conn|
    applied = conn.exec('SELECT version FROM schema_migrations').to_set { |r| r['version'] }
    files.each { |filepath| apply_migration(conn, filepath, applied) }
  end

  print_footer('Completed migrate')
end

def load_functions
  files = Dir["#{File.expand_path('features', ROOT_DIR)}/**/functions/**/*.sql"]
  print_header('Loading functions')
  errors = with_connection { |conn| run_function_files(conn, files) }
  report_functions_completion(errors)
end

def run_function_files(conn, files)
  files.each_with_object([]) do |filepath, errors|
    rel = relative_path(filepath)
    errors << rel if run_file(conn, filepath, rel) == :error
  end
end

def report_functions_completion(errors)
  if errors.empty?
    print_footer('Completed functions')
  else
    print_footer("Completed functions with errors: #{errors.join(', ')}", color: :error)
  end
end

def reset_database
  guard_reset_env!(ENV.fetch('APP_ENV'))
  drop_and_recreate_schema
  puts "\n#{Color.label('Database reset')} #{Color.success('(schema dropped and recreated)')}\n"
  run_scripts_in_folder('create_schema')
  %w[db:migrate db:functions db:seed].each { |t| Rake::Task[t].invoke }
  puts "\n#{Color.success('Reset complete')}\n\n"
end

def guard_reset_env!(env)
  return if %w[development test].include?(env)

  puts "\n#{Color.error("Can't run in '#{env}', do it manually or use 'rake db:migrate'")}\n\n"
  exit 1
end

def drop_and_recreate_schema
  with_connection do |conn|
    conn.exec('SET client_min_messages = WARNING')
    conn.exec('DROP SCHEMA public CASCADE')
    conn.exec('CREATE SCHEMA public')
  end
end

namespace :db do
  desc 'Run database migrations'
  task(:migrate) { run_migrations }

  desc 'Load/reload all database functions'
  task(:functions) { load_functions }

  desc 'Seed the database'
  task(:seed) { run_scripts_in_folder('seeds') }

  desc 'Reset database (development/testing only): drop schema, recreate, migrate, seed'
  task(:reset) { reset_database }
end
