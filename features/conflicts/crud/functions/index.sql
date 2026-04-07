BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_index(UUID);

CREATE FUNCTION conflicts_crud_index(p_user_id UUID)
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
    SELECT
      c.id,
      c.creator_id,
      c.title,
      c.description,
      c.favor,
      c.status::TEXT,
      c.created_at,
      c.updated_at
    FROM conflicts c
    WHERE c.creator_id = p_user_id
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMIT;
