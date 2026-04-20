# frozen_string_literal: true

require 'phlex'

module Porotutu
  class PhlexView < Phlex::HTML
    def initialize(csrf_token: nil, **attrs)
      @csrf_token = csrf_token
      super(**attrs)
    end

    def t(key, **interpolations) = Translations.t(key, **interpolations)

    def csrf_field
      input(type: 'hidden', name: 'csrf_token', value: @csrf_token)
    end

    def field_error(field, errors: nil)
      return unless errors&.key?(field)

      small(style: 'color: var(--pico-del-color);') { errors[field] }
    end

    def labeled_input(label_text, type:, name:, required: false)
      label do
        plain label_text
        input(type: type, name: name, required: required || nil)
      end
    end
  end
end
