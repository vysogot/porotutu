# frozen_string_literal: true

module Auth
  module Helpers
    module Paths
      VIEWS_DIR  = File.expand_path('../views', __dir__)
      ROOT_VIEWS = File.expand_path('../../../views', __dir__)

      def auth_erb(view, **options)
        erb view, { layout: :layout, layout_options: { views: ROOT_VIEWS } }
          .merge(options)
          .merge(views: VIEWS_DIR)
      end
    end
  end
end
