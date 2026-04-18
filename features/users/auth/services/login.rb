# frozen_string_literal: true

module Porotutu
  module Users
    module Auth
      module Services
        class Login
          extend Patterns::Service
          include Patterns::Query

          def call(params:)
            result = call_function('find_user_by_email', p_email: params[:email])
            row = result.first

            validate!(row, params[:password])

            Mappers::User.from_row(row)
          end

          private

          def validate!(row, password)
            raise Errors::InvalidCredentials unless row

            digest = BCrypt::Password.new(row['password_digest'])

            raise Errors::InvalidCredentials unless digest == password
          end
        end
      end
    end
  end
end
