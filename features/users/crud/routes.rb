# frozen_string_literal: true

module Users
  module Crud
    class Routes < Sinatra::Base
      include Helpers::Views

      get '/register' do
        users_erb :new
      end

      post '/users' do
        Handlers::Create.call(params:)

        redirect '/login'
      end
    end
  end
end
