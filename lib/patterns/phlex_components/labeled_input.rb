# frozen_string_literal: true

module Porotutu
  module PhlexComponents
    module LabeledInput
      def labeled_input(name, label_text:, type: 'text', value: nil, required: false,
                        errors: nil, maxlength: nil, placeholder: nil, autofocus: false)
        label(for: name) do
          plain label_text
          input(
            **{
              type: type,
              id: name,
              name: name,
              value: value,
              required: required || nil,
              maxlength: maxlength,
              placeholder: placeholder,
              autofocus: autofocus || nil
            }.compact
          )
          field_error(name, errors: errors)
        end
      end
    end
  end
end
