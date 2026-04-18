# frozen_string_literal: true

module Porotutu
  module Conflicts
    module Crud
      module Handlers
        class Index
          extend Patterns::Service

          def call(current_user_id:)
            conflicts = Services::FindMany.call(user_id: current_user_id)

            {
              current_user_id:,
              drafts: conflicts[:drafts]
            }
          end
        end
      end
    end
  end
end
