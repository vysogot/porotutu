# frozen_string_literal: true

module Habits
  module Services
    class Update < Patterns::Service
      def call(params:)
        Habit
          .where(id: params[:id])
          .update(name: params[:name])
          .first
      end
    end
  end
end
