# frozen_string_literal: true

module Conflicts
  module Services
    class List
      extend Patterns::Service

      def call(couple_id:, user_id:)
        result = DB.connection.exec_params(
          'SELECT * FROM get_conflicts($1, $2)',
          [couple_id, user_id]
        )

        conflicts = result.map do |row|
          Conflict.from_row(row)
        end

        {
          drafts: conflicts.select { |c| c.status == 'draft' && c.creator_id == user_id },
          pending_mine: conflicts.select { |c| c.status == 'pending' && c.creator_id == user_id },
          pending_partner: conflicts.select { |c| c.status == 'pending' && c.creator_id != user_id },
          active: conflicts.select { |c| c.status == 'active' }
        }
      end
    end
  end
end
