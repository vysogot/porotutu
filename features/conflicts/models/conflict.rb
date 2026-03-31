# frozen_string_literal: true

module Conflicts
  Conflict = Data.define(
    :id, :couple_id, :creator_id,
    :title, :description, :favor,
    :status, :deadline, :recur_count,
    :proposed_status, :proposed_by_id,
    :created_at, :updated_at, :archived_at
  ) do
    def self.from_row(row)
      new(
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
