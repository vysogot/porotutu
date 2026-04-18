# frozen_string_literal: true

module Porotutu
  module Conflicts
    module Crud
      module Services
        class FindOne
          extend Patterns::Service
          include Patterns::Query

          def call(id:, user_id:)
            result = call_function('conflicts_crud_find_one', p_id: id, p_creator_id: user_id)
            row = result.first
            return nil unless row

            Mappers::Conflict.from_row(row)
          end
        end
      end
    end
  end
end
