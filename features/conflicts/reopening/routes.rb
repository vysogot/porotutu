# frozen_string_literal: true

module Conflicts
  module Reopening
    class Routes < Sinatra::Base
      post '/conflicts/:id/reopen' do
        Handlers::Reopen.call(params:)

        redirect "/conflicts/#{params[:id]}", 303
      end
    end
  end
end
