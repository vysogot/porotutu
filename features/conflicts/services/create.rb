# frozen_string_literal: true

module Conflicts
  module Services
    class Create
      extend Patterns::Service

      def call(couple_id:, creator_id:, title:, description:, favor:)
        result = DB.connection.exec_params(
          'SELECT * FROM create_conflict($1, $2, $3, $4, $5)',
          [couple_id, creator_id, title, description, favor]
        )

        row_to_conflict(result.first)
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
