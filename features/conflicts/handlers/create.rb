# frozen_string_literal: true

module Conflicts
  module Handlers
    class Create
      extend Patterns::Service

      def call(params:, current_user_id:)
        couple = Couples::Services::FindForUser.call(user_id: current_user_id)
        raise 'No couple found for user' unless couple

        params = params.slice(:title, :description, :favor)

        conflict = Services::Create.call(
          couple_id: couple.id,
          creator_id: current_user_id,
          title: params[:title],
          description: params[:description].to_s,
          favor: params[:favor].presence
        )

        { conflict:, current_user_id: }
      end
    end
  end
end
