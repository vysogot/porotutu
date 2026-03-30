# frozen_string_literal: true

module Patterns
  class Authentication
    PUBLIC_PATHS = {
      'GET'  => %w[/login /register],
      'POST' => %w[/session /users]
    }.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      if authenticated?(env)
        @app.call(env)
      else
        [302, { 'location' => '/login' }, []]
      end
    end

    private

    def authenticated?(env)
      session = env['rack.session']
      return true if session && session[:user_id]

      method = env['REQUEST_METHOD']
      path   = env['PATH_INFO']

      PUBLIC_PATHS.fetch(method, []).include?(path)
    end
  end
end
