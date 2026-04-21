BEGIN;

DROP FUNCTION IF EXISTS conflicts_delete(UUID, UUID);

CREATE FUNCTION conflicts_delete(p_id UUID, p_user_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
    DELETE FROM conflicts
    WHERE id = p_id AND creator_id = p_user_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
