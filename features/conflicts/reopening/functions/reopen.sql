BEGIN;

DROP FUNCTION IF EXISTS conflicts_reopening_reopen(UUID);

CREATE FUNCTION conflicts_reopening_reopen(p_id UUID)
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
