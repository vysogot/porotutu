CREATE OR REPLACE FUNCTION accept_resolution(p_id UUID)
RETURNS VOID AS $$
DECLARE
  v_conflict conflicts%ROWTYPE;
BEGIN
  SELECT * INTO v_conflict FROM conflicts WHERE id = p_id;

  INSERT INTO conflict_resolutions (conflict_id, status, favor)
  VALUES (p_id, v_conflict.proposed_status, v_conflict.favor);

  UPDATE conflicts
  SET
    status = v_conflict.proposed_status::conflict_status,
    archived_at = CURRENT_TIMESTAMP,
    proposed_status = NULL,
    proposed_by_id = NULL,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
