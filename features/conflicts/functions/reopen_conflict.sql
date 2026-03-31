BEGIN;

DROP FUNCTION IF EXISTS reopen_conflict(UUID);

CREATE FUNCTION reopen_conflict(p_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
  UPDATE conflicts
  SET
    status = 'active',
    deadline = CURRENT_TIMESTAMP + INTERVAL '7 days',
    recur_count = recur_count + 1,
    archived_at = NULL,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
