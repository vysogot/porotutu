BEGIN;

DROP FUNCTION IF EXISTS conflicts_find_many(UUID);

CREATE FUNCTION conflicts_find_many(p_user_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM conflicts c
    WHERE c.creator_id = p_user_id
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

COMMIT;
