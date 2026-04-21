# frozen_string_literal: true

module Porotutu
  module Users
    class CreateService
      extend Service
      include DbFunctionCall

      def call(params:)
        password_digest = BCrypt::Password.create(params[:password])

        result = call_function(
          'users_create',
          p_email: params[:email],
          p_password_digest: password_digest
        )

        UserMapper.from_row(result.first)
      end
    end
  end
end
