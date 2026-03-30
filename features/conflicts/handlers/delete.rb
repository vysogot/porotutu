# frozen_string_literal: true

module Conflicts
  module Handlers
    class Delete
      extend Patterns::Service

      def call(params:)
        Services::Delete.call(params:)

        {
          id: params[:id]
        }
      end
    end
  end
end
