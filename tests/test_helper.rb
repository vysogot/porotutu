# frozen_string_literal: true

require 'dotenv/load'
require 'minitest/autorun'
require 'pg'
require 'bcrypt'
require 'zeitwerk'

require_relative '../patterns/database'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('..', __dir__))
loader.collapse(File.expand_path('../features', __dir__))
Dir.glob(File.expand_path('../features/*/models', __dir__)).each do |dir|
  loader.collapse(dir)
end
loader.ignore(
  File.expand_path('../app.rb', __dir__),
  File.expand_path('../patterns/database.rb', __dir__),
  __dir__
)
loader.setup

module Conflicts
  module Tests
    class TestCase < Minitest::Test
      def setup
        DB.connection.exec('BEGIN')
      end

      def teardown
        DB.connection.exec('ROLLBACK')
      end
    end
  end
end
