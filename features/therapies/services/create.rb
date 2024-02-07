# frozen_string_literal: true

module Therapies
  module Services
    class Create < Patterns::Service
      def call(params:)
        Therapy.create(params)
      end
    end
  end
end
