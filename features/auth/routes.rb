# frozen_string_literal: true

module Auth
  class Routes < Sinatra::Base
    include Helpers::Paths

    get '/login' do
      auth_erb :new, locals: { error: nil }
    end

    post '/session' do
      locals = Handlers::Login.call(params:)

      if locals[:user]
        session[:user_id] = locals[:user].id
        redirect '/'
      else
        auth_erb :new, locals: { error: locals[:error] }
      end
    end

    post '/logout' do
      session.clear
      redirect '/login'
    end
  end
end
