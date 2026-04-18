# frozen_string_literal: true

require 'dotenv/load'
require 'minitest/autorun'
require 'pg'
require 'bcrypt'
require 'zeitwerk'

root = File.expand_path('..', __dir__)

loader = Zeitwerk::Loader.new
loader.push_dir(root)
loader.collapse("#{root}/features")
loader.ignore("#{root}/app.rb", __dir__)
loader.setup

module Tests
  class TestCase < Minitest::Test
    def setup
      @_db_conn = Patterns::Database.pool.checkout
      @_db_conn.exec('BEGIN')
    end

    def teardown
      @_db_conn.exec('ROLLBACK')
      Patterns::Database.pool.checkin
    end
  end
end
