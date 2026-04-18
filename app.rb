# frozen_string_literal: true

require 'zeitwerk'
require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'pg'
require 'debug'

require_relative 'patterns/db'

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.collapse("#{__dir__}/features")
loader.ignore(
  "#{__dir__}/app.rb",
  "#{__dir__}/patterns/db.rb",
  "#{__dir__}/tests"
)
loader.setup

class Sinatra::Base
  set :turbo_stream, 'text/vnd.turbo-stream.html'
end

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload File.join(__dir__, 'patterns/**/*.rb')
    also_reload File.join(__dir__, 'features/**/*.rb')
    also_reload File.join(__dir__, 'mappers/**/*.rb')
  end

  set :public_folder, File.join(__dir__, 'public')

  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET')
  set :sessions, key: 'porotutu.session', httponly: true, same_site: :lax

  use Patterns::CsrfProtection
  use Patterns::Authentication

  use Users::Routes
  use Conflicts::Routes

  get '/' do
    redirect '/conflicts'
  end
end
