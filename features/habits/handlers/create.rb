# frozen_string_literal: true

module Habits
  module Handlers
    class Create < Patterns::Service
      def call(params:)
        params.slice!(:name)
        habits = Services::Create.call(params:)

        {
          id: habits.id,
          name: habits.name
        }
      end
    end
  end
end
