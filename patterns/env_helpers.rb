# frozen_string_literal: true

module Porotutu
  module Patterns
    module EnvHelpers
      module_function

      def production? = ENV['APP_ENV'] == 'production'
      def testing? = ENV['APP_ENV'] == 'testing'
      def development? = ENV['APP_ENV'] == 'development'
      def staging? = ENV['APP_ENV'] == 'staging'
      def public? = production? || staging?
    end
  end
end
