# frozen_string_literal: true

module Porotutu
  module Conflicts
    class Routes < Sinatra::Base
      use Crud::Routes
    end
  end
end
