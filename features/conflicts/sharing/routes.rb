# frozen_string_literal: true

module Conflicts
  module Sharing
    class Routes < Sinatra::Base
      include Helpers::Paths

      get '/conflicts/reveal' do
        view :readiness, layout: false
      end

      post '/conflicts/reveal' do
        locals = Handlers::Reveal.call(current_user_id: session['user_id'])

        content_type settings.turbo_stream
        view :reveal_stream, layout: false, locals:
      end

      post '/conflicts/:id/share' do
        locals = Handlers::Share.call(params:, current_user_id: session['user_id'])

        content_type settings.turbo_stream
        view :share, layout: false, locals:
      end

      post '/conflicts/:id/unshare' do
        locals = Handlers::Unshare.call(params:, current_user_id: session['user_id'])

        content_type settings.turbo_stream
        view :unshare, layout: false, locals:
      end
    end
  end
end
