# frozen_string_literal: true

module Porotutu
  module Conflicts
    module Crud
      module Handlers
        class Update
          extend Patterns::Service

          def call(params:)
            params = params.slice(:id, :title, :description, :favor)

            Validators::Conflict.call(params:)

            conflict = Services::Update.call(
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
  end
end
