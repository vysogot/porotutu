# frozen_string_literal: true

module Users
  module Helpers
    module Paths
      VIEWS_DIR  = File.expand_path('../views', __dir__)
      ROOT_LAYOUTS = File.expand_path('../../../layouts', __dir__)

      def users_erb(view, **options)
        erb view, { layout: :main, layout_options: { views: ROOT_LAYOUTS } }
          .merge(options)
          .merge(views: VIEWS_DIR)
      end
    end
  end
end
