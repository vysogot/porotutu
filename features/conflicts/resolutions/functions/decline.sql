BEGIN;

DROP FUNCTION IF EXISTS conflicts_resolutions_decline(UUID);

CREATE FUNCTION conflicts_resolutions_decline(p_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
  UPDATE conflicts
  SET
    proposed_status = NULL,
    proposed_by_id = NULL,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
