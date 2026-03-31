# frozen_string_literal: true

module Conflicts
  module Handlers
    class Home
      extend Patterns::Service

      def call(current_user_id:)
        couple = Couples::Services::FindForUser.call(user_id: current_user_id)

        return { couple: nil, drafts: [], pending_mine: [], pending_partner: [], active: [], current_user_id: } unless couple

        lists = Services::List.call(couple_id: couple.id, user_id: current_user_id)

        {
          couple:,
          current_user_id:,
          drafts: lists[:drafts],
          pending_mine: lists[:pending_mine],
          pending_partner: lists[:pending_partner],
          active: lists[:active]
        }
      end
    end
  end
end
