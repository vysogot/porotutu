# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class Show
        extend Patterns::Service

        def call(id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_crud_show($1)',
            [id]
          )

          row = result.first
          return nil unless row

          Mappers::Conflict.from_row(row)
        end
      end
    end
  end
end
