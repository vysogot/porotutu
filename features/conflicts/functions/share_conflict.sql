BEGIN;

DROP FUNCTION IF EXISTS share_conflict(UUID);

CREATE FUNCTION share_conflict(p_id UUID)
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
