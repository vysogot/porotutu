# frozen_string_literal: true

module Conflicts
  module Handlers
    class AcceptResolution
      extend Patterns::Service

      def call(params:)
        Services::AcceptResolution.call(id: params[:id])

        { id: params[:id] }
      end
    end
  end
end
