# frozen_string_literal: true

module Therapies
  module Handlers
    class Delete < Patterns::Service
      def call(params:)
        Services::Delete.call(params:)

        {
          id: params[:id]
        }
      end
    end
  end
end
