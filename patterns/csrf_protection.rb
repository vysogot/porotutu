# frozen_string_literal: true

require 'securerandom'

module Porotutu
  module Patterns
    class CsrfProtection
      MUTATING_METHODS = %w[POST PATCH DELETE].freeze

      def initialize(app)
        @app = app
      end

      def call(env)
        session = env['rack.session']
        session['csrf_token'] ||= SecureRandom.hex(32)

        if MUTATING_METHODS.include?(env['REQUEST_METHOD']) && ENV['APP_ENV'] != 'test'
          request = Rack::Request.new(env)
          token = request.params['csrf_token']

          unless token && Rack::Utils.secure_compare(token, session['csrf_token'])
            return [403, { 'content-type' => 'text/plain' }, ['Forbidden']]
          end
        end

        @app.call(env)
      end
    end
  end
end
