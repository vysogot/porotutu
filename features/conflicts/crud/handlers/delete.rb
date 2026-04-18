# frozen_string_literal: true

module Porotutu
  module Conflicts
    module Crud
      module Handlers
        class Delete
          extend Patterns::Service

          def call(params:, current_user_id:)
            Services::Delete.call(id: params[:id], user_id: current_user_id)

            nil
          end
        end
      end
    end
  end
end
