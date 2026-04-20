# frozen_string_literal: true

module Porotutu
  module Users
    module SessionHelper
      def post_login_path
        Patterns::ReturnTo.pop(session) || '/conflicts'
      end
    end
  end
end
