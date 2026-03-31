# frozen_string_literal: true

module Conflicts
  module Handlers
    class AcceptResolution
      extend Patterns::Service

      def call(params:)
        conflict = Services::AcceptResolution.call(id: params[:id])

        { conflict: }
      end
    end
  end
end
