# frozen_string_literal: true

module Porotutu
  module Conflicts
    class ShowHandler
      extend Service

      def call(params:, current_user_id:)
        conflict = FindOneService.call(id: params[:id], user_id: current_user_id)

        { conflict:, current_user_id: }
      end
    end
  end
end
