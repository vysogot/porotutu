CREATE OR REPLACE FUNCTION get_conflict(p_id INT)
RETURNS TABLE(id INT, name VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT conflicts.id, conflicts.name FROM conflicts WHERE conflicts.id = p_id;
END;
$$ LANGUAGE plpgsql;
