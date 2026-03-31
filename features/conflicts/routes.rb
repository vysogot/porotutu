# frozen_string_literal: true

module Conflicts
  class Routes < Sinatra::Base
    include Helpers::Paths

    get '/conflicts' do
      locals = Handlers::Home.call(current_user_id: session['user_id'])

      conflicts_erb :home, locals:
    end

    get '/conflicts/new' do
      conflicts_erb :new
    end

    get '/conflicts/reveal' do
      conflicts_erb :readiness, layout: false
    end

    post '/conflicts' do
      locals = Handlers::Create.call(params:, current_user_id: session['user_id'])

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :create, layout: false, locals:
    end

    post '/conflicts/reveal' do
      locals = Handlers::Reveal.call(current_user_id: session['user_id'])

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :reveal_stream, layout: false, locals:
    end

    get '/conflicts/:id' do
      locals = Handlers::Show.call(params:, current_user_id: session['user_id'])

      conflicts_erb :show, locals:
    end

    get '/conflicts/:id/edit' do
      locals = Handlers::Edit.call(params:)

      conflicts_erb :edit, locals:
    end

    patch '/conflicts/:id' do
      locals = Handlers::Update.call(params:, current_user_id: session['user_id'])

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :update, layout: false, locals:
    end

    delete '/conflicts/:id' do
      locals = Handlers::Delete.call(params:)

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :delete, layout: false, locals:
    end

    post '/conflicts/:id/share' do
      locals = Handlers::Share.call(params:, current_user_id: session['user_id'])

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :share, layout: false, locals:
    end

    post '/conflicts/:id/unshare' do
      locals = Handlers::Unshare.call(params:, current_user_id: session['user_id'])

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :unshare, layout: false, locals:
    end

    post '/conflicts/:id/propose' do
      locals = Handlers::ProposeResolution.call(params:, current_user_id: session['user_id'])

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :propose, layout: false, locals:
    end

    post '/conflicts/:id/accept' do
      locals = Handlers::AcceptResolution.call(params:)

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :accept, layout: false, locals:
    end

    post '/conflicts/:id/decline' do
      locals = Handlers::DeclineResolution.call(params:, current_user_id: session['user_id'])

      content_type 'text/vnd.turbo-stream.html'
      conflicts_erb :decline, layout: false, locals:
    end

    post '/conflicts/:id/reopen' do
      Handlers::Reopen.call(params:)

      redirect "/conflicts/#{params[:id]}", 303
    end
  end
end
