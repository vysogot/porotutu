BEGIN;

DROP FUNCTION IF EXISTS conflicts_sharing_reveal(UUID, UUID);

CREATE FUNCTION conflicts_sharing_reveal(p_couple_id UUID, p_partner_id UUID)
RETURNS TABLE(
  id UUID,
  couple_id UUID,
  creator_id UUID,
  title TEXT,
  description TEXT,
  favor TEXT,
  status TEXT,
  deadline TIMESTAMP,
  recur_count INTEGER,
  proposed_status TEXT,
  proposed_by_id UUID,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  archived_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
    UPDATE conflicts
    SET
      status = 'active',
      deadline = CURRENT_TIMESTAMP + INTERVAL '7 days',
      updated_at = CURRENT_TIMESTAMP
    WHERE conflicts.status = 'pending'
      AND conflicts.creator_id = p_partner_id
      AND conflicts.couple_id = p_couple_id
    RETURNING
      conflicts.id,
      conflicts.couple_id,
      conflicts.creator_id,
      conflicts.title,
      conflicts.description,
      conflicts.favor,
      conflicts.status::TEXT,
      conflicts.deadline,
      conflicts.recur_count,
      conflicts.proposed_status,
      conflicts.proposed_by_id,
      conflicts.created_at,
      conflicts.updated_at,
      conflicts.archived_at;
END;
$$ LANGUAGE plpgsql;

COMMIT;
