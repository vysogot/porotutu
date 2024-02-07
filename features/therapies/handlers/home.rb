# frozen_string_literal: true

module Therapies
  module Handlers
    class Home < Patterns::Service
      def call
        {
          therapies: Therapy.all
        }
      end
    end
  end
end
