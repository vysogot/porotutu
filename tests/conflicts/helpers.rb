module Conflicts
  module Tests
    module Helpers
      def create_user(email: "test_#{rand(100_000)}@example.com")
        password_digest = BCrypt::Password.create('password', cost: BCrypt::Engine::MIN_COST).to_s

        result = DB.connection.exec_params(
          'SELECT * FROM create_user($1, $2)',
          [email, password_digest]
        )

        result.first['id']
      end

      def create_couple(user1_id:, user2_id:)
        result = DB.connection.exec_params(
          'SELECT * FROM create_couple($1, $2)',
          [user1_id, user2_id]
        )

        result.first['id']
      end

      def create_conflict(couple_id:, creator_id:, title: 'Test Conflict', description: '', favor: nil, status: nil)
        result = DB.connection.exec_params(
          'SELECT * FROM create_conflict($1, $2, $3, $4, $5)',
          [couple_id, creator_id, title, description, favor]
        )

        row = result.first

        if status && status != 'draft'
          DB.connection.exec_params(
            'UPDATE conflicts SET status = $1::conflict_status WHERE id = $2',
            [status, row['id']]
          )
        end

        row['id']
      end
    end
  end
end
