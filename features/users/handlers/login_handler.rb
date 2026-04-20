# frozen_string_literal: true

module Porotutu
  module Users
    class LoginHandler
      extend Service

      def call(params:)
        params = params.slice(:email, :password)

        { user: LoginService.call(params:) }
      end
    end
  end
end
