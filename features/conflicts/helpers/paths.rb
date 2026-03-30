# frozen_string_literal: true

module Conflicts
  module Helpers
    module Paths
      VIEWS_DIR = 'features/conflicts/views'

      def conflicts_erb(view, **options)
        erb view, options.merge(views: VIEWS_DIR)
      end
    end
  end
end
