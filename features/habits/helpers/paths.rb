# frozen_string_literal: true

module Habits
  module Helpers
    module Paths
      VIEWS_DIR = 'features/habits/views'

      def habits_erb(view, **options)
        erb view, options.merge(views: VIEWS_DIR)
      end
    end
  end
end
