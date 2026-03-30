# frozen_string_literal: true

module Auth
  module Handlers
    class Login
      extend Patterns::Service

      def call(params:)
        params = params.slice(:email, :password)
        user = Services::Login.call(params:)

        if user
          { user: }
        else
          { user: nil, error: 'Invalid email or password.' }
        end
      end
    end
  end
end
