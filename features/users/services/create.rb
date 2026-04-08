# frozen_string_literal: true

module Users
  module Services
    class Create
      extend Patterns::Service

      def call(params:)
        password_digest = BCrypt::Password.create(params[:password])

        result = DB.connection.exec_params(
          'SELECT * FROM create_user($1, $2)',
          [params[:email], password_digest]
        )

        row = result.first

        ::Mappers::User.from_row(row.except('password_digest'))
      end
    end
  end
end
