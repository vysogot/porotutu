# frozen_string_literal: true

module Therapies
  module Services
    class Update < Patterns::Service
      def call(params:)
        Therapy
          .where(id: params[:id])
          .update(name: params[:name])
          .first
      end
    end
  end
end
