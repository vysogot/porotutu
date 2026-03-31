CREATE OR REPLACE FUNCTION decline_resolution(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE conflicts
  SET
    proposed_status = NULL,
    proposed_by_id = NULL,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
