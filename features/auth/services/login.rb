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
        return nil unless row
        return nil unless BCrypt::Password.new(row['password_digest']) == params[:password]

        Users::User.new(id: row['id'], email: row['email'])
      end
    end
  end
end
