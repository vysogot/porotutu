BEGIN;

DROP FUNCTION IF EXISTS conflicts_sharing_unshare(UUID);

CREATE FUNCTION conflicts_sharing_unshare(p_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
  UPDATE conflicts
  SET status = 'draft', updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
