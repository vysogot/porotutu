# frozen_string_literal: true

require 'pg'
require_relative 'support/color'

ROOT_DIR = File.expand_path('..', __dir__)
DB_DIR = File.join(ROOT_DIR, 'db')
Color = Porotutu::Tasks::Support::Color

require_relative 'support/helpers'

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    print_header("Running scripts in 'migrations'")

    with_db do |conn|
      applied = conn.exec(
        'SELECT version FROM schema_migrations'
      ).to_set { |r| r['version'] }

      Dir["#{DB_DIR}/migrations/*.sql"].each do |filepath|
        version = File.basename(filepath).split('_').first

        if applied.include?(version)
          rel = filepath.delete_prefix("#{ROOT_DIR}/")
          puts "#{Color.path(rel)} #{Color.skipped('=> Skipped (already applied)')}"
          next
        end

        recorder = lambda {
          conn.exec_params(
            'INSERT INTO schema_migrations (version) VALUES ($1)',
            [version]
          )
        }

        exit 1 if run_sql_file(conn, filepath, &recorder) == :error
      end
    end

    print_footer('Completed migrations')
  end

  desc 'Load/reload all database functions'
  task :functions do
    print_header("Running scripts in 'functions'")

    failed = []
    with_db do |conn|
      Dir["#{ROOT_DIR}/features/**/functions/**/*.sql"].each do |filepath|
        rel = filepath.delete_prefix("#{ROOT_DIR}/")
        failed << rel if run_sql_file(conn, filepath) == :error
      end
    end

    if failed.empty?
      print_footer('Completed functions')
    else
      print_footer("Completed functions with errors: #{failed.join(', ')}", color: :error)
    end
  end

  desc 'Seed the database'
  task :seed do
    print_header("Running scripts in 'seeds'")

    with_db do |conn|
      Dir["#{DB_DIR}/seeds/*.sql"].each do |filepath|
        exit 1 if run_sql_file(conn, filepath) == :error
      end
    end

    print_footer('Completed seeds')
  end

  desc 'Reset database (development/testing only): drop schema, recreate, migrate, seed'
  task :reset do
    if %w[production staging].include?(ENV['APP_ENV'])
      warn "\n#{Color.error("Refusing to reset in '#{ENV.fetch('APP_ENV')}'")}\n\n"
      exit 1
    end

    with_db do |conn|
      conn.exec('SET client_min_messages = WARNING')
      conn.exec('DROP SCHEMA public CASCADE')
      conn.exec('CREATE SCHEMA public')
    end
    puts "\n#{Color.label('Database reset')} #{Color.success('(schema dropped and recreated)')}\n"

    print_header("Running scripts in 'bootstrap'")
    with_db do |conn|
      Dir["#{DB_DIR}/bootstrap/*.sql"].each do |filepath|
        exit 1 if run_sql_file(conn, filepath) == :error
      end
    end
    print_footer('Completed bootstrap')

    %w[db:migrate db:functions db:seed].each { |t| Rake::Task[t].invoke }

    puts "\n#{Color.success('Reset complete')}\n\n"
  end
end
