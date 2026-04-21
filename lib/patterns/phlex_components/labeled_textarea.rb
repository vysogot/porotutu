# frozen_string_literal: true

module Porotutu
  module PhlexComponents
    module LabeledTextarea
      def labeled_textarea(name, label_text:, value: nil, rows: 4, required: false,
                           errors: nil, maxlength: nil, placeholder: nil)
        label(for: name) do
          plain label_text
          textarea(
            **{
              id: name,
              name: name,
              rows: rows,
              required: required || nil,
              maxlength: maxlength,
              placeholder: placeholder
            }.compact
          ) { value }
          field_error(name, errors: errors)
        end
      end
    end
  end
end
