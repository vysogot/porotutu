# frozen_string_literal: true

module Habits
  module Services
    class Create < Patterns::Service
      def call(params:)
        Habit.create(params)
      end
    end
  end
end
