# frozen_string_literal: true

module Therapies
  module Handlers
    class Create < Patterns::Service
      def call(params:)
        therapy = Services::Create.call(params:)

        {
          id: therapy.id,
          name: therapy.name
        }
      end
    end
  end
end
