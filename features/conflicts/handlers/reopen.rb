# frozen_string_literal: true

module Conflicts
  module Handlers
    class Reopen
      extend Patterns::Service

      def call(params:)
        conflict = Services::Reopen.call(id: params[:id])

        { conflict: }
      end
    end
  end
end
