CREATE OR REPLACE FUNCTION update_conflict(p_id INT, p_name TEXT)
RETURNS TABLE(id INT, name VARCHAR) AS $$
BEGIN
  RETURN QUERY
    UPDATE conflicts
    SET name = p_name, updated_at = CURRENT_TIMESTAMP
    WHERE conflicts.id = p_id
    RETURNING conflicts.id, conflicts.name;
END;
$$ LANGUAGE plpgsql;
