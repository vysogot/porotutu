# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class Delete
        extend Patterns::Service
        include Patterns::Query

        def call(id:, user_id:)
          result = call_function('conflicts_crud_delete', [id, user_id])
          row = result.first

          row && Mappers::Conflict.from_row(row)
        end
      end
    end
  end
end
