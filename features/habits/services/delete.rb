# frozen_string_literal: true

module Habits
  module Services
    class Delete
      extend Patterns::Service

      def call(params:)
        Habit.destroy(params[:id])
      end
    end
  end
end
