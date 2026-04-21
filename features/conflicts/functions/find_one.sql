BEGIN;

DROP FUNCTION IF EXISTS conflicts_find_one(UUID, UUID);

CREATE FUNCTION conflicts_find_one(p_id UUID, p_creator_id UUID)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM conflicts c
    WHERE c.id = p_id AND c.creator_id = p_creator_id;
END;
$$ LANGUAGE plpgsql;

COMMIT;
