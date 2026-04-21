# frozen_string_literal: true

require 'dotenv/load'
require 'minitest/autorun'
require 'pg'
require 'bcrypt'

root = File.expand_path('..', __dir__)

module Porotutu; end

require_relative "#{root}/lib/initializers/zeitwerk"
Porotutu::Zeitwerk.setup(root: root, extra_ignores: [__dir__])

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
