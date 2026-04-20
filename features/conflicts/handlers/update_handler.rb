# frozen_string_literal: true

module Porotutu
  module Conflicts
    class UpdateHandler
      extend Patterns::Service

      def call(params:)
        params = params.slice(:id, :title, :description, :favor)

        ConflictValidator.call(params:)

        conflict = UpdateService.call(
          id: params[:id],
          title: params[:title],
          description: params[:description],
          favor: params[:favor]
        )

        { conflict: }
      end
    end
  end
end
