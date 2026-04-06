BEGIN;

DROP FUNCTION IF EXISTS conflicts_resolutions_accept(UUID);

CREATE FUNCTION conflicts_resolutions_accept(p_id UUID)
RETURNS SETOF conflicts AS $$
DECLARE
  v_conflict conflicts%ROWTYPE;
BEGIN
  SELECT * INTO v_conflict FROM conflicts WHERE id = p_id;

  INSERT INTO conflict_resolutions (conflict_id, status, favor)
  VALUES (p_id, v_conflict.proposed_status, v_conflict.favor);

  RETURN QUERY
  UPDATE conflicts
  SET
    status = v_conflict.proposed_status::conflict_status,
    archived_at = CURRENT_TIMESTAMP,
    proposed_status = NULL,
    proposed_by_id = NULL,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
