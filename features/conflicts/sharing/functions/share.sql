BEGIN;

DROP FUNCTION IF EXISTS conflicts_sharing_share(UUID);

CREATE FUNCTION conflicts_sharing_share(p_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
  UPDATE conflicts
  SET status = 'pending', updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
