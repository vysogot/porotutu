# frozen_string_literal: true

require 'pg'
require_relative 'support/runner'
require_relative 'support/color'
require_relative '../env_helpers'
require_relative '../../patterns/service'
require_relative '../../patterns/db'
require_relative 'db/migrate'
require_relative 'db/functions'
require_relative 'db/seed'
require_relative 'db/reset'

ROOT_DIR = File.expand_path('../..', __dir__)
DB_DIR = File.join(ROOT_DIR, 'db')

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    Porotutu::Tasks::Db::Migrate.call(root_dir: ROOT_DIR, db_dir: DB_DIR)
  end

  desc 'Load/reload all database functions'
  task :functions do
    Porotutu::Tasks::Db::Functions.call(root_dir: ROOT_DIR)
  end

  desc 'Seed the database'
  task :seed do
    Porotutu::Tasks::Db::Seed.call(root_dir: ROOT_DIR, db_dir: DB_DIR)
  end

  desc 'Reset database (development/testing only): drop schema, recreate, migrate, seed'
  task :reset do
    Porotutu::Tasks::Db::Reset.call(root_dir: ROOT_DIR, db_dir: DB_DIR)

    %w[db:migrate db:functions db:seed].each { |t| Rake::Task[t].invoke }

    puts "\n#{Porotutu::Tasks::Support::Color.success('Reset complete')}\n\n"
  end
end
