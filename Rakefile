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

def run_scripts_in_folder(folder)
  files = Dir["#{File.join(DB_DIR, folder)}/*.sql"].sort

  puts "\n#{Color.header("--- Running scripts in '#{folder}' ---")}\n\n"

  with_connection do |conn|
    files.each do |filepath|
      rel = relative_path(filepath)
      run_sql_file(conn, filepath)
      puts "#{Color.path(rel)} #{Color.success("=> Success")}"
    rescue PG::Error => e
      puts "#{Color.path(rel)} #{Color.error("=> Error:")} #{e.message}"
      exit 1
    end
  end

  puts "\n#{Color.success("Completed #{folder}")}\n"
end

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    files = Dir["#{File.join(DB_DIR, 'migrate')}/*.sql"].sort

    puts "\n#{Color.header("--- Running scripts in 'migrate' ---")}\n\n"

    with_connection do |conn|
      applied = conn.exec('SELECT version FROM schema_migrations').map { |r| r['version'] }.to_set

      files.each do |filepath|
        rel     = relative_path(filepath)
        version = File.basename(filepath).split('_').first

        if applied.include?(version)
          puts "#{Color.path(rel)} #{Color.skipped("=> Skipped (already applied)")}"
          next
        end

        run_sql_file(conn, filepath)
        conn.exec_params('INSERT INTO schema_migrations (version) VALUES ($1)', [version])
        puts "#{Color.path(rel)} #{Color.success("=> Success")}"
      rescue PG::Error => e
        puts "#{Color.path(rel)} #{Color.error("=> Error:")} #{e.message}"
        exit 1
      end
    end

    puts "\n#{Color.success("Completed migrate")}\n"
  end

  desc 'Load/reload all database functions'
  task :functions do
    files = Dir["#{File.expand_path('features', ROOT_DIR)}/**/functions/**/*.sql"].sort

    puts "\n#{Color.header("--- Loading functions ---")}\n\n"

    errors = []

    with_connection do |conn|
      files.each do |filepath|
        rel = relative_path(filepath)
        run_sql_file(conn, filepath)
        puts "#{Color.path(rel)} #{Color.success("=> Success")}"
      rescue PG::Error => e
        puts "#{Color.path(rel)} #{Color.error("=> Error:")} #{e.message}"
        errors << rel
      end
    end

    if errors.empty?
      puts "\n#{Color.success("Completed functions")}\n"
    else
      puts "\n#{Color.error("Completed functions with errors:")} #{errors.join(', ')}\n"
    end
  end

  desc 'Seed the database'
  task :seed do
    run_scripts_in_folder('seeds')
  end

  desc 'Reset database (development/testing only): drop schema, recreate, migrate, seed'
  task :reset do
    env = ENV.fetch('APP_ENV')

    unless %w[development test].include?(env)
      puts "\n#{Color.error("Can't run in '#{env}', do it manually or use 'rake db:migrate'")}\n\n"
      exit 1
    end

    with_connection do |conn|
      conn.exec('SET client_min_messages = WARNING')
      conn.exec('DROP SCHEMA public CASCADE')
      conn.exec('CREATE SCHEMA public')
    end

    puts "\n#{Color.label("Database reset")} #{Color.success("(schema dropped and recreated)")}\n"

    run_scripts_in_folder('create_schema')
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:functions'].invoke
    Rake::Task['db:seed'].invoke

    puts "\n#{Color.success("Reset complete")}\n\n"
  end
end
