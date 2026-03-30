# frozen_string_literal: true

module Auth
  module Services
    class Login
      extend Patterns::Service

      def call(params:)
        result = DB.connection.exec_params(
          'SELECT * FROM find_user_by_email($1)',
          [params[:email]]
        )

        row = result.first

        validate!(row, params[:password])

        Users::User.new(id: row['id'], email: row['email'])
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
