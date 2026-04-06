# frozen_string_literal: true

module Conflicts
  module Crud
    module Handlers
      class Home
        extend Patterns::Service

        def call(current_user_id:)
          conflicts = Services::Index.call(user_id: current_user_id)

          {
            couple:,
            current_user_id:,
            drafts: conflicts[:drafts],
            pending_mine: conflicts[:pending_mine],
            pending_partner: conflicts[:pending_partner],
            active: conflicts[:active],
            archived: conflicts[:archived]
          }
        end
      end
    end
  end
end
