# frozen_string_literal: true

module Conflicts
  module Resolutions
    class Routes < Sinatra::Base
      include Helpers::Paths

      post '/conflicts/:id/propose' do
        locals = Handlers::Propose.call(params:, current_user_id: session['user_id'])

        content_type settings.turbo_stream
        view :propose, layout: false, locals:
      end

      post '/conflicts/:id/accept' do
        locals = Handlers::Accept.call(params:)

        content_type settings.turbo_stream
        view :accept, layout: false, locals:
      end

      post '/conflicts/:id/decline' do
        locals = Handlers::Decline.call(params:, current_user_id: session['user_id'])

        content_type settings.turbo_stream
        view :decline, layout: false, locals:
      end
    end
  end
end
