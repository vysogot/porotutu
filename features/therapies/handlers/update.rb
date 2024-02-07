# frozen_string_literal: true

module Therapies
  module Handlers
    class Update < Patterns::Service
      def call(params:)
        therapy = Services::Update.call(params:)

        {
          id: therapy.id,
          name: therapy.name
        }
      end
    end
  end
end
