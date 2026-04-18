# frozen_string_literal: true

module Porotutu
  module Mappers
    Conflict = Data.define(
      :id,
      :creator_id,
      :title,
      :description,
      :favor,
      :status,
      :created_at,
      :updated_at
    ) do
      def self.from_row(row)
        new(
          id: row['id'],
          creator_id: row['creator_id'],
          title: row['title'],
          description: row['description'],
          favor: row['favor'],
          status: row['status'],
          created_at: row['created_at'],
          updated_at: row['updated_at']
        )
      end
    end
  end
end
