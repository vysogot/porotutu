# frozen_string_literal: true

module Habits
  module Handlers
    class Edit
      extend Patterns::Service

      def call(params:)
        habits = Habit.find(params[:id])

        {
          id: habits.id,
          name: habits.name
        }
      end
    end
  end
end
