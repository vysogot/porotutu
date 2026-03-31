BEGIN;

DROP FUNCTION IF EXISTS propose_resolution(UUID, TEXT, UUID);

CREATE FUNCTION propose_resolution(p_id UUID, p_status TEXT, p_proposed_by_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
  UPDATE conflicts
  SET
    proposed_status = p_status,
    proposed_by_id = p_proposed_by_id,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
