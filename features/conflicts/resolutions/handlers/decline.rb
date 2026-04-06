# frozen_string_literal: true

module Conflicts
  module Resolutions
    module Handlers
      class Decline
        extend Patterns::Service

        def call(params:, current_user_id:)
          conflict = Services::Decline.call(id: params[:id])

          { conflict:, current_user_id: }
        end
      end
    end
  end
end
