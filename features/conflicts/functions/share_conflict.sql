CREATE OR REPLACE FUNCTION share_conflict(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE conflicts
  SET status = 'pending', updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
