# frozen_string_literal: true

module Conflicts
  module Crud
    module Handlers
      class Create
        extend Patterns::Service
        include Constants

        def call(params:, current_user_id:)
          params = params.slice(:title, :description, :favor)

          Validators::Conflict.call(params:)

          conflict = Services::Create.call(
            user_id: current_user_id,
            title: params[:title],
            description: params[:description],
            favor: params[:favor],
            status: STATUSES[:draft]
          )

          { conflict:, current_user_id: }
        end
      end
    end
  end
end
