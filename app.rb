# frozen_string_literal: true

require 'zeitwerk'
require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'pg'

require_relative 'patterns/database'

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.collapse("#{__dir__}/features")
loader.collapse(Dir.glob("#{__dir__}/features/*/models"))
loader.ignore(
  "#{__dir__}/app.rb",
  "#{__dir__}/patterns/database.rb"
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
  end

  set :public_folder, File.join(__dir__, 'public')

  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET')
  set :sessions, key: 'porotutu.session', httponly: true, same_site: :lax

  use Patterns::Authentication

  use Auth::Routes
  use Users::Routes
  use Conflicts::Routes
end
