# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class FindMany
        extend Patterns::Service
        include Patterns::Query

        def call(user_id:)
          result = call_function('conflicts_crud_find_many', [user_id])

          conflicts = result.map do |row|
            Mappers::Conflict.from_row(row)
          end

          {
            drafts: conflicts.select { |c| c.status == 'draft' }
          }
        end
      end
    end
  end
end
