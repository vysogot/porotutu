# frozen_string_literal: true

require 'dotenv/load'
require 'pg'

DATABASE_URL = ENV.fetch('DATABASE_URL', 'postgres://localhost/porotutu')
DB_DIR = File.expand_path('db', __dir__)

def run_scripts_in_folder(folder)
  conn = PG.connect(DATABASE_URL)
  path = File.join(DB_DIR, folder)
  files = Dir["#{path}/*.sql"].sort

  puts "\n--- Running scripts in '#{folder}' ---\n\n"

  files.each do |filepath|
    filename = File.basename(filepath)
    sql = File.read(filepath)

    conn.exec(sql)
    puts "#{filename} => Success"
  rescue PG::Error => e
    puts "\n#{filename} => Error: #{e.message}"
    exit 1
  end

  puts "\nCompleted #{folder}\n"
ensure
  conn&.finish
end

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    conn = PG.connect(DATABASE_URL)
    path = File.join(DB_DIR, 'migrate')
    files = Dir["#{path}/*.sql"].sort

    puts "\n--- Running scripts in 'migrate' ---\n\n"

    files.each do |filepath|
      filename = File.basename(filepath)
      version = filename.split('_').first

      applied = conn.exec_params('SELECT 1 FROM schema_migrations WHERE version = $1', [version]).any?

      if applied
        puts "#{filename} => Skipped (already applied)"
        next
      end

      sql = File.read(filepath)
      conn.exec(sql)
      conn.exec_params('INSERT INTO schema_migrations (version) VALUES ($1)', [version])
      puts "#{filename} => Success"
    rescue PG::Error => e
      puts "\n#{filename} => Error: #{e.message}"
      exit 1
    end

    puts "\nCompleted migrate\n"
  ensure
    conn&.finish
  end

  desc 'Load/reload all database functions'
  task :functions do
    conn = PG.connect(DATABASE_URL)
    files = Dir["#{File.expand_path('features', __dir__)}/**/functions/**/*.sql"].sort

    puts "\n--- Loading functions ---\n\n"

    files.each do |filepath|
      filename = filepath.delete_prefix("#{__dir__}/")
      sql = File.read(filepath)

      conn.exec(sql)
      puts "#{filename} => Success"
    rescue PG::Error => e
      puts "\n#{filename} => Error: #{e.message}"
      exit 1
    end

    puts "\nCompleted functions\n"
  ensure
    conn&.finish
  end

  desc 'Seed the database'
  task :seed do
    run_scripts_in_folder('seeds')
  end

  desc 'Reset database (development/testing only): drop schema, recreate, migrate, seed'
  task :reset do
    env = ENV.fetch('APP_ENV', 'development')

    unless %w[development testing].include?(env)
      puts "\nCan't run in '#{env}', do it manually or use 'rake db:migrate'\n\n"
      exit 1
    end

    conn = PG.connect(DATABASE_URL)
    conn.exec('SET client_min_messages = WARNING')
    conn.exec('DROP SCHEMA public CASCADE')
    conn.exec('CREATE SCHEMA public')
    conn.finish

    puts "\nDatabase reset (schema dropped and recreated)\n"

    run_scripts_in_folder('create_schema')
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:functions'].invoke
    Rake::Task['db:seed'].invoke

    puts "\nReset db completed\n\n"
  end
end
