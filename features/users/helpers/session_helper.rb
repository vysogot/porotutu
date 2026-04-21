# frozen_string_literal: true

module Porotutu
  module Users
    module SessionHelper
      include Conflicts::PathsHelper

      def post_login_path
        ReturnTo.pop(session) || conflicts_path
      end
    end
  end
end
