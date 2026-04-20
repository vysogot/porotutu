# frozen_string_literal: true

module Porotutu
  module Validations
    private

    def validate_presence(errors, params, *fields)
      fields.each do |field|
        value = params[field]
        errors[field] = 'is required' if value.nil? || value.strip.empty?
      end
    end

    def validate_length(errors, value, field, max)
      return if errors.key?(field)
      return if value.nil?

      errors[field] = "must be #{max} characters or less" if value.length > max
    end
  end
end
