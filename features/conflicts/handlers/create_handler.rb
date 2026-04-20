# frozen_string_literal: true

module Porotutu
  module Conflicts
    class CreateHandler
      extend Service

      def call(params:, current_user_id:)
        params = params.slice(:title, :description, :favor)

        ConflictValidator.call(params:)

        conflict = CreateService.call(
          user_id: current_user_id,
          title: params[:title],
          description: params[:description],
          favor: params[:favor],
          status: 'draft'
        )

        { conflict:, current_user_id: }
      end
    end
  end
end
