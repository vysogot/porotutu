# frozen_string_literal: true

module Porotutu
  module Users
    class CreateService
      extend Patterns::Service
      include Patterns::Query

      def call(params:)
        password_digest = BCrypt::Password.create(params[:password])

        result = call_function(
          'create_user',
          p_email: params[:email],
          p_password_digest: password_digest
        )

        UserMapper.from_row(result.first)
      end
    end
  end
end
