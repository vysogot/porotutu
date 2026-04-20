# frozen_string_literal: true

module Porotutu
  module Conflicts
    class EditHandler
      extend Patterns::Service

      def call(params:, current_user_id:)
        conflict = FindOneService.call(id: params[:id], user_id: current_user_id)

        { conflict: }
      end
    end
  end
end
