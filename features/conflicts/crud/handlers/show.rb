# frozen_string_literal: true

module Conflicts
  module Crud
    module Handlers
      class Show
        extend Patterns::Service

        def call(params:, current_user_id:)
          conflict = Services::FindOne.call(id: params[:id], user_id: current_user_id)

          { conflict:, current_user_id: }
        end
      end
    end
  end
end
