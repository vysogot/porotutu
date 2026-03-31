BEGIN;

DROP FUNCTION IF EXISTS unshare_conflict(UUID);

CREATE FUNCTION unshare_conflict(p_id UUID)
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
