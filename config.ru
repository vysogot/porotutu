# frozen_string_literal: true

require 'rack/unreloader'
require 'pry'

Unreloader = Rack::Unreloader.new { App }
Unreloader.require './app.rb'

run Unreloader
