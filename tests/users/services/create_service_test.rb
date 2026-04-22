# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Users
    class CreateServiceTest < Tests::TestCase
      def test_creates_a_user_and_returns_a_mapper
        email = "alice-#{SecureRandom.hex(4)}@example.com"

        user = CreateService.call(params: { email: email, password: 'hunter22' })

        assert_kind_of UserMapper, user
        assert_equal email, user.email
        assert_kind_of Time, user.created_at
        refute_respond_to user, :password_digest
      end

      def test_stores_a_bcrypt_digest_not_the_plain_password
        email = "bob-#{SecureRandom.hex(4)}@example.com"
        password = 'hunter22'

        CreateService.call(params: { email: email, password: password })

        row = TestDb.fetch_one('SELECT password_digest FROM users WHERE email = $1', [email])
        digest = BCrypt::Password.new(row['password_digest'])

        assert_equal digest, password
        refute_equal password, row['password_digest']
      end
    end
  end
end
