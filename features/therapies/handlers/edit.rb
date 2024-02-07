# frozen_string_literal: true

module Therapies
  module Handlers
    class Edit < Patterns::Service
      def call(params:)
        therapy = Therapy.find(params[:id])

        {
          id: therapy.id,
          name: therapy.name
        }
      end
    end
  end
end
