# frozen_string_literal: true

module Conflicts
  module Handlers
    class Reveal
      extend Patterns::Service

      def call(current_user_id:)
        couple = Couples::Services::FindForUser.call(user_id: current_user_id)
        partner_id = couple.partner1_id == current_user_id ? couple.partner2_id : couple.partner1_id

        revealed = Services::Reveal.call(couple_id: couple.id, partner_id:)

        { revealed:, current_user_id: }
      end
    end
  end
end
