# frozen_string_literal: true

require 'dotenv/load'
require 'minitest/autorun'
require 'pg'
require 'bcrypt'
require 'zeitwerk'

require_relative '../patterns/db'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('..', __dir__))
loader.collapse(File.expand_path('../features', __dir__))
loader.ignore(
  File.expand_path('../app.rb', __dir__),
  File.expand_path('../patterns/db.rb', __dir__),
  __dir__
)
loader.setup

module Tests
  class TestCase < Minitest::Test
    def setup
      @_db_conn = DB.pool.checkout
      @_db_conn.exec('BEGIN')
    end

    def teardown
      @_db_conn.exec('ROLLBACK')
      DB.pool.checkin
    end
  end
end
