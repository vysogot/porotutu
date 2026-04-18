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
loader.collapse("#{root}/features")
loader.ignore(
  "#{root}/app.rb",
  "#{root}/bin",
  "#{root}/lib",
  "#{root}/db",
  "#{root}/ksiaki",
  "#{root}/public",
  "#{root}/layouts",
  "#{root}/partials",
  "#{root}/locales",
  __dir__
)
loader.setup

module Porotutu # rubocop:disable Style/OneClassPerFile
  module Tests
    class TestCase < Minitest::Test
      def setup
        @_db_conn = Patterns::Db.pool.checkout
        @_db_conn.exec('BEGIN')
      end

      def teardown
        @_db_conn.exec('ROLLBACK')
        Patterns::Db.pool.checkin
      end
    end
  end
end
