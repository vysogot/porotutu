# frozen_string_literal: true

module Porotutu
  class Authentication
    PUBLIC_PATHS = {
      'GET' => %w[/login /register],
      'POST' => %w[/session /users]
    }.freeze

    PUBLIC_PATH_PREFIXES = %w[/stylesheets/ /javascript/ /images/].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      if authenticated?(env)
        @app.call(env)
      else
        ReturnTo.set(env['rack.session'], env)
        [302, { 'location' => '/login' }, []]
      end
    end

    private

    def authenticated?(env)
      session = env['rack.session']
      return true if session && session['user_id']

      method = env['REQUEST_METHOD']
      path   = env['PATH_INFO']

      return true if method == 'GET' && PUBLIC_PATH_PREFIXES.any? { |p| path.start_with?(p) }

      PUBLIC_PATHS.fetch(method, []).include?(path)
    end
  end
end
