# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class Create
        extend Patterns::Service

        def call(user_id:, title:, description:, favor:, status:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_crud_create($1, $2, $3, $4, $5)',
            [user_id, title, description, favor, status]
          )

          Mappers::Conflict.from_row(result.first)
        end
      end
    end
  end
end
