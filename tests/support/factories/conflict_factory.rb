# frozen_string_literal: true

module Porotutu
  module Tests
    module Factories
      module ConflictFactory
        def self.create(conn:, creator_id: nil, title: nil, description: nil, favor: nil, status: nil)
          creator_id ||= UserFactory.create(conn: conn)['id']
          title ||= "Conflict #{SecureRandom.hex(4)}"
          conn.exec_params(
            <<~SQL,
              INSERT INTO conflicts (creator_id, title, description, favor, status)
              VALUES ($1, $2, $3, $4, $5)
              RETURNING *
            SQL
            [creator_id, title, description, favor, status]
          ).first
        end
      end
    end
  end
end
