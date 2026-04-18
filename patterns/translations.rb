# frozen_string_literal: true

require 'yaml'

module Patterns
  module Translations
    LOCALES_PATH = File.expand_path('../locales/en.yml', __dir__)
    MISSING_PREFIX = 'TRANSLATE!!: '

    class << self
      def t(key, **interpolations)
        translation = lookup(key)

        return "#{MISSING_PREFIX}#{key}" if translation.nil?
        return translation if interpolations.empty?

        interpolate(translation, interpolations)
      end

      private

      def translations
        mtime = File.mtime(LOCALES_PATH)

        if @translations.nil? || @loaded_at != mtime
          @translations = YAML.safe_load_file(LOCALES_PATH)
          @loaded_at = mtime
        end

        @translations
      end

      def lookup(key)
        key.to_s.split('.').reduce(translations) do |node, part|
          break nil unless node.is_a?(Hash)

          node[part]
        end
      end

      def interpolate(translation, interpolations)
        interpolations.reduce(translation) do |acc, (name, value)|
          acc.gsub("{{#{name}}}", value.to_s)
        end
      end
    end
  end
end
