BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_update(UUID, TEXT, TEXT, TEXT);

CREATE FUNCTION conflicts_crud_update(
  p_id UUID,
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
  created_at TIMESTAMP,
  updated_at TIMESTAMP
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
      conflicts.id,
      conflicts.creator_id,
      conflicts.title,
      conflicts.description,
      conflicts.favor,
      conflicts.status::TEXT,
      conflicts.created_at,
      conflicts.updated_at;
END;
$$ LANGUAGE plpgsql;

COMMIT;
