BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_find_by_id(UUID);

CREATE FUNCTION conflicts_crud_find_by_id(p_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM conflicts c
    WHERE c.id = p_id;
END;
$$ LANGUAGE plpgsql;

COMMIT;
