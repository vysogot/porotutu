# frozen_string_literal: true

require 'dotenv/load'
require 'minitest/autorun'
require 'pg'
require 'bcrypt'
require 'zeitwerk'

root = File.expand_path('..', __dir__)

module Porotutu; end

loader = Zeitwerk::Loader.new
loader.push_dir(root, namespace: Porotutu)
loader.collapse("#{root}/lib")
loader.collapse("#{root}/lib/*")
loader.collapse("#{root}/features")
loader.collapse("#{root}/features/*/{services,handlers,validators,helpers,errors,mappers,views}")
loader.ignore(
  "#{root}/app.rb",
  "#{root}/bin",
  "#{root}/tasks",
  "#{root}/db",
  "#{root}/ksiaki",
  "#{root}/public",
  "#{root}/locales",
  "#{root}/lib/styles",
  __dir__
)
loader.setup

module Porotutu # rubocop:disable Style/OneClassPerFile
  module Tests
    class TestCase < Minitest::Test
      def setup
        @_db_conn = DbConnection.pool.checkout
        @_db_conn.exec('BEGIN')
      end

      def teardown
        @_db_conn.exec('ROLLBACK')
        DbConnection.pool.checkin
      end
    end
  end
end
