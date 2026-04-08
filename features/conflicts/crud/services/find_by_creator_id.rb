# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class FindByCreatorId
        extend Patterns::Service
        include Constants

        def call(user_id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_crud_find_by_creator_id($1)',
            [user_id]
          )

          conflicts = result.map do |row|
            Mappers::Conflict.from_row(row)
          end

          {
            drafts: conflicts.select { |c| c.status == STATUSES[:draft] }
          }
        end
      end
    end
  end
end
