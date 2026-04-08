# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class FindOne
        extend Patterns::Service

        def call(id:, user_id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_crud_find_one($1, $2)',
            [id, user_id]
          )

          row = result.first
          return nil unless row

          Mappers::Conflict.from_row(row)
        end
      end
    end
  end
end
