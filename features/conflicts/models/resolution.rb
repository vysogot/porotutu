# frozen_string_literal: true

module Conflicts
  Resolution = Data.define(:id, :conflict_id, :status, :favor, :resolved_at)
end
