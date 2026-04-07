# frozen_string_literal: true

module Conflicts
  module Crud
    module Handlers
      class Index
        extend Patterns::Service

        def call(current_user_id:)
          conflicts = Services::Index.call(user_id: current_user_id)

          {
            current_user_id:,
            drafts: conflicts[:drafts],
            active: conflicts[:active]
          }
        end
      end
    end
  end
end
