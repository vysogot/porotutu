CREATE OR REPLACE FUNCTION get_conflicts()
RETURNS TABLE(id UUID, name VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT conflicts.id, conflicts.name FROM conflicts ORDER BY id;
END;
$$ LANGUAGE plpgsql;
