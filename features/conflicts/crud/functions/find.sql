BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_find(UUID);

CREATE FUNCTION conflicts_crud_find(p_id UUID)
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
    WHERE c.id = p_id;
END;
$$ LANGUAGE plpgsql;

COMMIT;
