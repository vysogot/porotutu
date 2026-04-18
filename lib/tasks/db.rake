# frozen_string_literal: true

require_relative 'support/runner'
require_relative 'support/color'
require_relative '../env_helpers'

DATABASE_URL = ENV.fetch('DATABASE_URL', 'postgres://localhost/porotutu')
ROOT_DIR = File.expand_path('../..', __dir__)
DB_DIR = File.join(ROOT_DIR, 'db')

namespace :db do # rubocop:disable Metrics/BlockLength
  desc 'Run database migrations'
  task :migrate do
    files = Dir["#{DB_DIR}/migrate/*.sql"]
    Runner.print_header("Running scripts in 'migrate'")

    Runner.with_connection(DATABASE_URL) do |conn|
      applied = conn.exec('SELECT version FROM schema_migrations').to_set { |r| r['version'] }

      files.each do |filepath|
        rel = Runner.relative_path(filepath, ROOT_DIR)
        version = File.basename(filepath).split('_').first

        if applied.include?(version)
          puts "#{Color.path(rel)} #{Color.skipped('=> Skipped (already applied)')}"
          next
        end

        record = -> { conn.exec_params('INSERT INTO schema_migrations (version) VALUES ($1)', [version]) }
        exit 1 if Runner.run_file(conn, filepath, rel, &record) == :error
      end
    end

    Runner.print_footer('Completed migrate')
  end

  desc 'Load/reload all database functions'
  task :functions do
    files = Dir["#{ROOT_DIR}/features/**/functions/**/*.sql"]
    Runner.print_header('Loading functions')

    errors = Runner.with_connection(DATABASE_URL) do |conn|
      files.each_with_object([]) do |filepath, failed|
        rel = Runner.relative_path(filepath, ROOT_DIR)
        failed << rel if Runner.run_file(conn, filepath, rel) == :error
      end
    end

    if errors.empty?
      Runner.print_footer('Completed functions')
    else
      Runner.print_footer("Completed functions with errors: #{errors.join(', ')}", color: :error)
    end
  end

  desc 'Seed the database'
  task :seed do
    files = Dir["#{DB_DIR}/seeds/*.sql"]
    Runner.print_header("Running scripts in 'seeds'")

    Runner.with_connection(DATABASE_URL) do |conn|
      files.each do |filepath|
        rel = Runner.relative_path(filepath, ROOT_DIR)
        exit 1 if Runner.run_file(conn, filepath, rel) == :error
      end
    end

    Runner.print_footer('Completed seeds')
  end

  desc 'Reset database (development/testing only): drop schema, recreate, migrate, seed'
  task :reset do
    if EnvHelpers.public?
      warn "\n#{Color.error("Refusing to reset in '#{ENV.fetch('APP_ENV')}'")}\n\n"
      exit 1
    end

    Runner.with_connection(DATABASE_URL) do |conn|
      conn.exec('SET client_min_messages = WARNING')
      conn.exec('DROP SCHEMA public CASCADE')
      conn.exec('CREATE SCHEMA public')
    end
    puts "\n#{Color.label('Database reset')} #{Color.success('(schema dropped and recreated)')}\n"

    files = Dir["#{DB_DIR}/create_schema/*.sql"]
    Runner.print_header("Running scripts in 'create_schema'")
    Runner.with_connection(DATABASE_URL) do |conn|
      files.each do |filepath|
        rel = Runner.relative_path(filepath, ROOT_DIR)
        exit 1 if Runner.run_file(conn, filepath, rel) == :error
      end
    end
    Runner.print_footer('Completed create_schema')

    %w[db:migrate db:functions db:seed].each { |t| Rake::Task[t].invoke }

    puts "\n#{Color.success('Reset complete')}\n\n"
  end
end
