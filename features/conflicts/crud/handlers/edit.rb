# frozen_string_literal: true

module Conflicts
  module Crud
    module Handlers
      class Edit
        extend Patterns::Service

        def call(params:)
          conflict = Services::Find.call(id: params[:id])

          { conflict: }
        end
      end
    end
  end
end
