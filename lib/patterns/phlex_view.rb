# frozen_string_literal: true

require 'phlex'

module Porotutu
  class PhlexView < Phlex::HTML
    include PhlexComponents::LabeledInput
    include PhlexComponents::LabeledTextarea
    include PhlexComponents::ProtectedForm

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

      small { errors[field] }
    end
  end
end
