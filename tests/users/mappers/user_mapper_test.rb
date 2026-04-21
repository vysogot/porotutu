# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Users
    class UserMapperTest < Minitest::Test
      def test_from_row_maps_expected_columns
        row = {
          'id' => 'uuid-1',
          'email' => 'a@b.com',
          'created_at' => Time.now,
          'updated_at' => nil,
          'password_digest' => 'secret-digest'
        }

        user = UserMapper.from_row(row)

        assert_equal 'uuid-1', user.id
        assert_equal 'a@b.com', user.email
        assert_kind_of Time, user.created_at
        assert_nil user.updated_at
      end

      def test_does_not_expose_password_digest
        row = {
          'id' => 'uuid-1',
          'email' => 'a@b.com',
          'created_at' => Time.now,
          'updated_at' => nil,
          'password_digest' => 'secret-digest'
        }

        user = UserMapper.from_row(row)

        refute_respond_to user, :password_digest
        refute_includes user.to_h.keys, :password_digest
      end
    end
  end
end
