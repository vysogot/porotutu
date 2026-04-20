# frozen_string_literal: true

module Porotutu
  module Users
    class Routes < Sinatra::Base
      include SessionHelper

      get '/register' do
        RegisterView.new(csrf_token: session['csrf_token']).call
      end

      post '/users' do
        CreateHandler.call(params:)

        redirect '/login'
      end

      get '/login' do
        LoginView.new(csrf_token: session['csrf_token']).call
      end

      post '/session' do
        locals = LoginHandler.call(params:)

        session['user_id'] = locals[:user].id
        redirect post_login_path, 303
      rescue InvalidCredentials => e
        LoginView.new(csrf_token: session['csrf_token'], error: e.message).call
      end

      post '/logout' do
        session.clear
        redirect '/login'
      end
    end
  end
end
