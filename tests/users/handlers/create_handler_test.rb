# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Users
    class CreateHandlerTest < Tests::TestCase
      def test_creates_a_user_and_returns_empty_locals
        email = "handler-#{SecureRandom.hex(4)}@example.com"

        locals = CreateHandler.call(
          params: { email: email, password: 'hunter22' }
        )

        assert_equal({}, locals)
        row = TestDb.fetch_one('SELECT id FROM users WHERE email = $1', [email])

        refute_nil row
      end

      def test_ignores_extra_params
        email = "handler-#{SecureRandom.hex(4)}@example.com"

        CreateHandler.call(
          params: { email: email, password: 'hunter22', admin: true, id: 'spoofed' }
        )

        row = TestDb.fetch_one('SELECT id FROM users WHERE email = $1', [email])

        refute_nil row
        refute_equal 'spoofed', row['id']
      end
    end
  end
end
