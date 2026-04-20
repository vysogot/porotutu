# frozen_string_literal: true

module Porotutu
  module Conflicts
    class FindManyService
      extend Patterns::Service
      include Patterns::Query

      def call(user_id:)
        result = call_function('conflicts_crud_find_many', p_user_id: user_id)

        conflicts = result.map do |row|
          ConflictMapper.from_row(row)
        end

        {
          drafts: conflicts.select { |c| c.status == 'draft' }
        }
      end
    end
  end
end
