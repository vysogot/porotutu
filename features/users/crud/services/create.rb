# frozen_string_literal: true

module Users
  module Crud
    module Services
      class Create
        extend Patterns::Service
        include Patterns::Query

        def call(params:)
          password_digest = BCrypt::Password.create(params[:password])

          result = call_function(
            'create_user',
            p_email: params[:email],
            p_password_digest: password_digest
          )

          ::Mappers::User.from_row(result.first)
        end
      end
    end
  end
end
