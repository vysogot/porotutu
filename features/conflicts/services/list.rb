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
          row_to_conflict(row)
        end

        {
          drafts: conflicts.select { |c| c.status == 'draft' && c.creator_id == user_id },
          pending_mine: conflicts.select { |c| c.status == 'pending' && c.creator_id == user_id },
          pending_partner: conflicts.select { |c| c.status == 'pending' && c.creator_id != user_id },
          active: conflicts.select { |c| c.status == 'active' }
        }
      end

      private

      def row_to_conflict(row)
        Conflict.new(
          id: row['id'],
          couple_id: row['couple_id'],
          creator_id: row['creator_id'],
          title: row['title'],
          description: row['description'],
          favor: row['favor'],
          status: row['status'],
          deadline: row['deadline'],
          recur_count: row['recur_count'].to_i,
          proposed_status: row['proposed_status'],
          proposed_by_id: row['proposed_by_id'],
          created_at: row['created_at'],
          updated_at: row['updated_at'],
          archived_at: row['archived_at']
        )
      end
    end
  end
end
