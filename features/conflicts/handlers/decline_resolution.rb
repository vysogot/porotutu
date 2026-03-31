# frozen_string_literal: true

module Conflicts
  module Handlers
    class DeclineResolution
      extend Patterns::Service

      def call(params:, current_user_id:)
        Services::DeclineResolution.call(id: params[:id])
        conflict = Services::Find.call(id: params[:id])

        { conflict:, current_user_id: }
      end
    end
  end
end
