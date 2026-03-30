# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'require_all'
require 'pg'

require_rel 'patterns'
require_rel 'features'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload File.join(__dir__, 'patterns/**/*.rb')
    also_reload File.join(__dir__, 'features/**/*.rb')
  end

  set :public_folder, File.join(__dir__, 'public')

  use Conflicts::Routes
end
