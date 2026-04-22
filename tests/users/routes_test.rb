# frozen_string_literal: true

require_relative '../test_helper'

module Porotutu
  module Users
    class RoutesTest < Tests::RequestTestCase
      def test_get_register_renders_the_form
        get '/register'

        assert_equal 200, last_response.status
        assert_includes last_response.body, 'action="/users"'
      end

      def test_get_login_renders_the_form
        get '/login'

        assert_equal 200, last_response.status
        assert_includes last_response.body, 'action="/session"'
      end

      def test_post_users_creates_a_user_and_redirects_to_login
        email = "routes-#{SecureRandom.hex(4)}@example.com"

        post '/users', email: email, password: 'hunter22'

        assert_equal 302, last_response.status
        assert_equal '/login', URI(last_response.location).path

        row = TestDb.fetch_one('SELECT id FROM users WHERE email = $1', [email])

        refute_nil row
      end

      def test_post_session_with_valid_credentials_logs_in_and_redirects
        email = "routes-login-#{SecureRandom.hex(4)}@example.com"
        password = 'hunter22'
        UserFactory.create(email: email, password: password)

        post '/session', email: email, password: password

        assert_equal 303, last_response.status
        assert_equal '/conflicts', URI(last_response.location).path
        assert last_request.session['user_id']
      end

      def test_post_session_with_bad_password_rerenders_login_without_session
        email = "routes-bad-#{SecureRandom.hex(4)}@example.com"
        UserFactory.create(email: email, password: 'hunter22')

        post '/session', email: email, password: 'wrong'

        assert_equal 200, last_response.status
        assert_includes last_response.body, 'action="/session"'
        assert_nil last_request.session['user_id']
      end

      def test_post_session_with_unknown_email_rerenders_login
        post '/session', email: 'nobody@example.com', password: 'hunter22'

        assert_equal 200, last_response.status
        assert_nil last_request.session['user_id']
      end

      def test_post_logout_clears_session_and_redirects_to_login
        row = UserFactory.create
        env 'rack.session', { 'user_id' => row['id'] }

        post '/logout'

        assert_equal 302, last_response.status
        assert_equal '/login', URI(last_response.location).path
        assert_nil last_request.session['user_id']
      end

      def test_protected_path_redirects_to_login_when_unauthenticated
        get '/conflicts'

        assert_equal 302, last_response.status
        assert_equal '/login', URI(last_response.location).path
      end
    end
  end
end
