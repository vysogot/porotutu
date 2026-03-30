CREATE OR REPLACE FUNCTION create_conflict(p_name TEXT)
RETURNS TABLE(id UUID, name VARCHAR) AS $$
BEGIN
  RETURN QUERY
    INSERT INTO conflicts (name) VALUES (p_name)
    RETURNING conflicts.id, conflicts.name;
END;
$$ LANGUAGE plpgsql;
