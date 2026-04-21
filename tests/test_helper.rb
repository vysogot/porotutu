# frozen_string_literal: true

require 'dotenv/load'
ENV['APP_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'pg'
require 'bcrypt'

BCrypt::Engine.cost = BCrypt::Engine::MIN_COST

root = File.expand_path('..', __dir__)

require_relative "#{root}/app"

Dir["#{__dir__}/support/**/*.rb"].each { |file| require file }

module Porotutu # rubocop:disable Style/OneClassPerFile
  module Tests
    class TestCase < Minitest::Test
      def setup
        @_db_conn = DbConnection.pool.checkout
        @_db_conn.exec('BEGIN')
        @_pinned_conn = @_db_conn
        DbConnection.singleton_class.prepend(PinnedConnection)
        Thread.current[:porotutu_pinned_conn] = @_db_conn
      end

      def teardown
        Thread.current[:porotutu_pinned_conn] = nil
        @_db_conn.exec('ROLLBACK')
        DbConnection.pool.checkin
      end
    end

    class RequestTestCase < TestCase
      include Rack::Test::Methods

      def app
        Porotutu::App
      end
    end

    module PinnedConnection
      def with(&block)
        pinned = Thread.current[:porotutu_pinned_conn]
        return super unless pinned

        block.call(pinned)
      end
    end
  end
end
