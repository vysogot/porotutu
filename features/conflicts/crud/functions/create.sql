BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_create(UUID, TEXT, TEXT, TEXT, TEXT);

CREATE FUNCTION conflicts_crud_create(
  p_creator_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_favor TEXT,
  p_status TEXT
)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
    INSERT INTO conflicts (creator_id, title, description, favor, status)
    VALUES (p_creator_id, p_title, p_description, p_favor, p_status)
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
