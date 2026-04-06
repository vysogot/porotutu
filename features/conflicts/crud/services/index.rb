# frozen_string_literal: true

module Conflicts
  module Crud
    module Services
      class Index
        extend Patterns::Service

        def call(user_id:)
          result = DB.connection.exec_params(
            'SELECT * FROM conflicts_crud_index($1)',
            [user_id]
          )

          conflicts = result.map do |row|
            Mappers::Conflict.from_row(row)
          end

          {
            drafts: conflicts.select { |c| c.status == 'draft' && c.creator_id == user_id },
            pending_mine: conflicts.select { |c| c.status == 'pending' && c.creator_id == user_id },
            pending_partner: conflicts.select { |c| c.status == 'pending' && c.creator_id != user_id },
            active: conflicts.select { |c| c.status == 'active' },
            archived: conflicts.select { |c| !c.archived_at.nil? }
          }
        end
      end
    end
  end
end
