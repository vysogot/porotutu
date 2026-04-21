# frozen_string_literal: true

module Porotutu
  module Conflicts
    module PathsHelper
      def conflicts_path = '/conflicts'
      def new_conflict_path = '/conflicts/new'
      def conflict_path(conflict) = "/conflicts/#{conflict.id}"
      def edit_conflict_path(conflict) = "/conflicts/#{conflict.id}/edit"
    end
  end
end
