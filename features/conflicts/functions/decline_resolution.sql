BEGIN;

DROP FUNCTION IF EXISTS decline_resolution(UUID);

CREATE FUNCTION decline_resolution(p_id UUID)
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
