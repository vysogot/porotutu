# frozen_string_literal: true

module Porotutu
  module Conflicts
    class IndexHandler
      extend Patterns::Service

      def call(current_user_id:)
        conflicts = FindManyService.call(user_id: current_user_id)

        {
          current_user_id:,
          drafts: conflicts[:drafts]
        }
      end
    end
  end
end
