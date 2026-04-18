# frozen_string_literal: true

module Porotutu
  module Users
    module Auth
      module Helpers
        module Session
          def post_login_path
            Patterns::ReturnTo.pop(session) || '/conflicts'
          end
        end
      end
    end
  end
end
