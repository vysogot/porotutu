# frozen_string_literal: true

module Conflicts
  module Resolutions
    module Handlers
      class Propose
        extend Patterns::Service

        def call(params:, current_user_id:)
          params = params.slice(:id, :status)

          conflict = Services::Propose.call(
            id: params[:id],
            status: params[:status],
            proposed_by_id: current_user_id
          )

          { conflict:, current_user_id: }
        end
      end
    end
  end
end
