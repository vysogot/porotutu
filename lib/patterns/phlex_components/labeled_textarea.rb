# frozen_string_literal: true

module Porotutu
  module PhlexComponents
    module LabeledTextarea
      def labeled_textarea(name, label_text:, value: nil, rows: 4, required: false,
                           errors: nil, maxlength: nil, placeholder: nil)
        wrapper_class = errors&.key?(name) ? 'field field--invalid' : 'field'

        div(class: wrapper_class) do
          label(for: name, class: 'field__label') { plain label_text }
          textarea(
            **{
              id: name,
              name: name,
              rows: rows,
              required: required || nil,
              maxlength: maxlength,
              placeholder: placeholder,
              class: 'field__textarea'
            }.compact
          ) { value }
          field_error(name, errors: errors)
        end
      end
    end
  end
end
