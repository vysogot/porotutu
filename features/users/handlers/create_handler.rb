# frozen_string_literal: true

module Porotutu
  module Users
    class CreateHandler
      extend Patterns::Service

      def call(params:)
        params = params.slice(:email, :password)

        CreateService.call(params:)

        {}
      end
    end
  end
end
