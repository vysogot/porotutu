# frozen_string_literal: true

module Conflicts
  module Crud
    module Handlers
      class Show
        extend Patterns::Service

        def call(params:, current_user_id:)
          conflict = Services::Find.call(id: params[:id])

          { conflict:, current_user_id: }
        end
      end
    end
  end
end
