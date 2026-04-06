# frozen_string_literal: true

module Conflicts
  module Handlers
    class Reveal
      extend Patterns::Service

      def call(current_user_id:)
        revealed = Services::Reveal.call(partner_id:)

        { revealed:, current_user_id: }
      end
    end
  end
end
