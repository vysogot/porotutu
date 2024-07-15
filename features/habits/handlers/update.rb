# frozen_string_literal: true

module Habits
  module Handlers
    class Update
      extend Patterns::Service

      def call(params:)
        habits = Services::Update.call(params:)

        {
          id: habits.id,
          name: habits.name
        }
      end
    end
  end
end
