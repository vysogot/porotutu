# frozen_string_literal: true

module Porotutu
  module Users
    class LoginService
      extend Service
      include DbFunctionCall

      def call(params:)
        result = call_function('users_find_by_email', p_email: params[:email])
        row = result.first

        validate!(row, params[:password])

        UserMapper.from_row(row)
      end

      private

      def validate!(row, password)
        raise InvalidCredentials unless row

        digest = BCrypt::Password.new(row['password_digest'])

        raise InvalidCredentials unless digest == password
      end
    end
  end
end
