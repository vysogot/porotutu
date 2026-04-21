# frozen_string_literal: true

module Porotutu
  module Tests
    module Factories
      module UserFactory
        def self.create(conn:, email: nil, password: 'hunter22')
          email ||= "user-#{SecureRandom.hex(4)}@example.com"
          digest = BCrypt::Password.create(password)
          conn.exec_params(
            'INSERT INTO users (email, password_digest) VALUES ($1, $2) RETURNING *',
            [email, digest]
          ).first
        end
      end
    end
  end
end
