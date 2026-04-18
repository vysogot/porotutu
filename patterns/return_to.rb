# frozen_string_literal: true

module Patterns
  module ReturnTo
    SESSION_KEY = 'return_to'
    SKIP_PATHS = %w[/login /logout /session].freeze

    def self.set(session, env)
      return unless env['REQUEST_METHOD'] == 'GET'

      path = env['PATH_INFO']
      return if SKIP_PATHS.include?(path)

      query = env['QUERY_STRING']
      full = query && !query.empty? ? "#{path}?#{query}" : path

      session[SESSION_KEY] = full if safe?(full)
    end

    def self.pop(session)
      path = session.delete(SESSION_KEY)
      safe?(path) ? path : nil
    end

    def self.safe?(path)
      return false unless path.is_a?(String)
      return false unless path.start_with?('/')
      return false if path.start_with?('//')
      return false if path.include?("\n") || path.include?("\r")

      true
    end
  end
end
