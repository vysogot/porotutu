BEGIN;

DROP FUNCTION IF EXISTS get_conflicts(UUID, UUID);

CREATE FUNCTION get_conflicts(p_couple_id UUID, p_user_id UUID)
RETURNS TABLE(
  id UUID, couple_id UUID, creator_id UUID,
  title TEXT, description TEXT, favor TEXT,
  status TEXT, deadline TIMESTAMP, recur_count INTEGER,
  proposed_status TEXT, proposed_by_id UUID,
  created_at TIMESTAMP, updated_at TIMESTAMP, archived_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      c.id, c.couple_id, c.creator_id,
      c.title, c.description, c.favor,
      c.status::TEXT, c.deadline, c.recur_count,
      c.proposed_status, c.proposed_by_id,
      c.created_at, c.updated_at, c.archived_at
    FROM conflicts c
    WHERE c.couple_id = p_couple_id
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMIT;
