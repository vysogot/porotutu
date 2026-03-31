CREATE OR REPLACE FUNCTION delete_conflict(p_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM conflicts WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
