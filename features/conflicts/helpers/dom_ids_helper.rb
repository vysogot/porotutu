# frozen_string_literal: true

module Porotutu
  module Conflicts
    module DomIdsHelper
      def conflict_frame_id(conflict) = "conflict-#{conflict.id}"
    end
  end
end
