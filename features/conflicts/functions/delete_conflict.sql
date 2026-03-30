CREATE OR REPLACE FUNCTION delete_conflict(p_id INT)
RETURNS VOID AS $$
BEGIN
  DELETE FROM conflicts WHERE conflicts.id = p_id;
END;
$$ LANGUAGE plpgsql;
