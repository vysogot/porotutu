# frozen_string_literal: true

module Conflicts
  module Handlers
    class Reopen
      extend Patterns::Service

      def call(params:)
        Services::Reopen.call(id: params[:id])

        { id: params[:id] }
      end
    end
  end
end
