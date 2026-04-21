# frozen_string_literal: true

module Porotutu
  module PhlexComponents
    module LabeledInput
      def labeled_input(name, label_text:, type: 'text', value: nil, required: false,
                        errors: nil, maxlength: nil, placeholder: nil, autofocus: false)
        wrapper_class = errors&.key?(name) ? 'field field--invalid' : 'field'

        div(class: wrapper_class) do
          label(for: name, class: 'field__label') { plain label_text }
          input(
            **{
              type: type,
              id: name,
              name: name,
              value: value,
              required: required || nil,
              maxlength: maxlength,
              placeholder: placeholder,
              autofocus: autofocus || nil,
              class: 'field__input'
            }.compact
          )
          field_error(name, errors: errors)
        end
      end
    end
  end
end
