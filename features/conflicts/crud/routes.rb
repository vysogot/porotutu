# frozen_string_literal: true

module Conflicts
  module Crud
    class Routes < Sinatra::Base
      include Helpers::Views

      get '/conflicts' do
        locals = Handlers::Index.call(current_user_id: session['user_id'])

        view :index, locals:
      end

      get '/conflicts/new' do
        view :new
      end

      get '/conflicts/:id' do
        locals = Handlers::Show.call(params:, current_user_id: session['user_id'])

        view :show, locals:
      end

      get '/conflicts/:id/edit' do
        locals = Handlers::Edit.call(params:)

        view :edit, locals:
      end

      post '/conflicts' do
        locals = Handlers::Create.call(params:, current_user_id: session['user_id'])

        content_type settings.turbo_stream
        view :show, locals:
      end

      patch '/conflicts/:id' do
        locals = Handlers::Update.call(params:, current_user_id: session['user_id'])

        content_type settings.turbo_stream
        view :update, layout: false, locals:
      end

      delete '/conflicts/:id' do
        locals = Handlers::Delete.call(params:)

        content_type settings.turbo_stream
        view :delete, layout: false, locals:
      end
    end
  end
end
