# frozen_string_literal: true

module Porotutu
  module Conflicts
    class Routes < Sinatra::Base
      get '/conflicts' do
        locals = IndexHandler.call(current_user_id: session['user_id'])

        IndexView.new(csrf_token: session['csrf_token'], **locals).call
      end

      get '/conflicts/new' do
        NewView.new(csrf_token: session['csrf_token']).call
      end

      get '/conflicts/:id' do
        locals = ShowHandler.call(params:, current_user_id: session['user_id'])

        ShowView.new(csrf_token: session['csrf_token'], **locals).call
      end

      get '/conflicts/:id/edit' do
        locals = EditHandler.call(params:, current_user_id: session['user_id'])

        EditView.new(
          csrf_token: session['csrf_token'],
          layout: !request.env['HTTP_TURBO_FRAME'],
          **locals
        ).call
      end

      post '/conflicts' do
        locals = CreateHandler.call(params:, current_user_id: session['user_id'])

        redirect "/conflicts/#{locals[:conflict].id}", 303
      rescue ValidationError => e
        status 422
        NewView.new(csrf_token: session['csrf_token'], errors: e.errors, params:).call
      end

      patch '/conflicts/:id' do
        locals = UpdateHandler.call(params:)

        content_type settings.turbo_stream
        UpdateView.new(csrf_token: session['csrf_token'], **locals).call
      rescue ValidationError => e
        status 422
        locals = EditHandler.call(params:, current_user_id: session['user_id'])
        EditView.new(csrf_token: session['csrf_token'], **locals, errors: e.errors, params:).call
      end

      delete '/conflicts/:id' do
        DeleteHandler.call(params:, current_user_id: session['user_id'])

        redirect '/conflicts', 303
      end
    end
  end
end
