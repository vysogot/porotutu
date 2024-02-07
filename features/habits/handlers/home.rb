# frozen_string_literal: true

module Habits
  module Handlers
    class Home < Patterns::Service
      def call
        {
          habits: Habit.all
        }
      end
    end
  end
end
