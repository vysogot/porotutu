# frozen_string_literal: true

module Conflicts
  module Resolutions
    module Handlers
      class Accept
        extend Patterns::Service

        def call(params:)
          conflict = Services::Accept.call(id: params[:id])

          { conflict: }
        end
      end
    end
  end
end
