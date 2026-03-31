# frozen_string_literal: true

module Conflicts
  Conflict = Data.define(
    :id, :couple_id, :creator_id,
    :title, :description, :favor,
    :status, :deadline, :recur_count,
    :proposed_status, :proposed_by_id,
    :created_at, :updated_at, :archived_at
  )
end
