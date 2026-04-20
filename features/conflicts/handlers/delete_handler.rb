# frozen_string_literal: true

module Porotutu
  module Conflicts
    class DeleteHandler
      extend Service

      def call(params:, current_user_id:)
        DeleteService.call(id: params[:id], user_id: current_user_id)

        nil
      end
    end
  end
end
