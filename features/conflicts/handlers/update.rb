# frozen_string_literal: true

module Conflicts
  module Handlers
    class Update
      extend Patterns::Service

      def call(params:, current_user_id:)
        params = params.slice(:id, :title, :description, :favor)

        conflict = Services::Update.call(
          id: params[:id],
          title: params[:title],
          description: params[:description].to_s,
          favor: params[:favor].presence
        )

        { conflict:, current_user_id: }
      end
    end
  end
end
