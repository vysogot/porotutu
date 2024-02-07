# frozen_string_literal: true

require 'sinatra'
require 'require_all'
require 'sinatra/activerecord'

set :database, { adapter: 'sqlite3', database: 'sqlite3:porotutu.sqlite3' }

require_rel 'patterns'
require_rel 'features'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  get '/' do
    locals = Therapies::Handlers::Home.call

    erb :home, views: 'features/therapies/views', locals:
  end

  get '/new' do
    erb :new, views: 'features/therapies/views'
  end

  post '/therapies' do
    locals = Therapies::Handlers::Create.call(params:)

    content_type 'text/vnd.turbo-stream.html'
    erb :create, views: 'features/therapies/views', locals:
  end

  get '/:id/edit' do
    locals = Therapies::Handlers::Edit.call(params:)

    erb :edit, views: 'features/therapies/views', locals:
  end

  put '/:id' do
    locals = Therapies::Handlers::Update.call(params:)

    erb :show, views: 'features/therapies/views', locals:
  end

  delete '/:id' do
    locals = Therapies::Handlers::Delete.call(params:)

    content_type 'text/vnd.turbo-stream.html'
    erb :delete, views: 'features/therapies/views', locals:
  end
end
