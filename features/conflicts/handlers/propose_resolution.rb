# frozen_string_literal: true

module Conflicts
  module Handlers
    class ProposeResolution
      extend Patterns::Service

      def call(params:, current_user_id:)
        params = params.slice(:id, :status)

        Services::ProposeResolution.call(
          id: params[:id],
          status: params[:status],
          proposed_by_id: current_user_id
        )

        conflict = Services::Find.call(id: params[:id])

        { conflict:, current_user_id: }
      end
    end
  end
end
