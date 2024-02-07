# frozen_string_literal: true

module Therapies
  module Services
    class Delete < Patterns::Service
      def call(params:)
        Therapy.destroy(params[:id])
      end
    end
  end
end
