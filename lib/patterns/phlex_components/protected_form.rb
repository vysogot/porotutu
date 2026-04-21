# frozen_string_literal: true

module Porotutu
  module PhlexComponents
    module ProtectedForm
      def protected_form(**attrs, &block)
        form(**attrs) do
          csrf_field
          yield if block
        end
      end
    end
  end
end
