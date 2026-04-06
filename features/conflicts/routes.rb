# frozen_string_literal: true

module Conflicts
  class Routes < Sinatra::Base
    use Crud::Routes
    use Sharing::Routes
    use Resolutions::Routes
    use Reopening::Routes
  end
end
