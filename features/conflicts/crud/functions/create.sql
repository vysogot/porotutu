BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_create(UUID, TEXT, TEXT, TEXT);

CREATE FUNCTION conflicts_crud_create(
  p_creator_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_favor TEXT
)
RETURNS TABLE(
  id UUID,
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
    INSERT INTO conflicts (creator_id, title, description, favor)
    VALUES (p_creator_id, p_title, COALESCE(p_description, ''), p_favor)
    RETURNING
      conflicts.id,
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
