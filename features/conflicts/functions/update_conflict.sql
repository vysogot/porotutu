CREATE OR REPLACE FUNCTION update_conflict(
  p_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_favor TEXT
)
RETURNS TABLE(
  id UUID, couple_id UUID, creator_id UUID,
  title TEXT, description TEXT, favor TEXT,
  status TEXT, deadline TIMESTAMP, recur_count INTEGER,
  proposed_status TEXT, proposed_by_id UUID,
  created_at TIMESTAMP, updated_at TIMESTAMP, archived_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
    UPDATE conflicts
    SET
      title = p_title,
      description = COALESCE(p_description, ''),
      favor = p_favor,
      updated_at = CURRENT_TIMESTAMP
    WHERE conflicts.id = p_id
    RETURNING
      conflicts.id, conflicts.couple_id, conflicts.creator_id,
      conflicts.title, conflicts.description, conflicts.favor,
      conflicts.status::TEXT, conflicts.deadline, conflicts.recur_count,
      conflicts.proposed_status, conflicts.proposed_by_id,
      conflicts.created_at, conflicts.updated_at, conflicts.archived_at;
END;
$$ LANGUAGE plpgsql;
