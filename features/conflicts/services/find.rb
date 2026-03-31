# frozen_string_literal: true

module Conflicts
  module Services
    class Find
      extend Patterns::Service

      def call(id:)
        result = DB.connection.exec_params(
          'SELECT * FROM get_conflict($1)',
          [id]
        )

        row = result.first
        return nil unless row

        row_to_conflict(row)
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
