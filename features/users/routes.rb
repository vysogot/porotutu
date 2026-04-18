# frozen_string_literal: true

module Porotutu
  module Users
    class Routes < Sinatra::Base
      use Crud::Routes
      use Auth::Routes
    end
  end
end
