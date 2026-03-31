CREATE OR REPLACE FUNCTION unshare_conflict(p_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE conflicts
  SET status = 'draft', updated_at = CURRENT_TIMESTAMP
  WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
