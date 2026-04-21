# frozen_string_literal: true

require_relative '../../test_helper'

module Porotutu
  module Users
    class PathsHelperTest < Minitest::Test
      include PathsHelper

      def test_exposes_user_and_session_paths
        assert_equal '/login', login_path
        assert_equal '/logout', logout_path
        assert_equal '/register', register_path
        assert_equal '/session', session_path
        assert_equal '/users', users_path
      end
    end
  end
end
