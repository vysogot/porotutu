BEGIN;

DROP FUNCTION IF EXISTS conflicts_update(UUID, TEXT, TEXT, TEXT);

CREATE FUNCTION conflicts_update(
  p_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_favor TEXT
)
RETURNS SETOF conflicts AS $$
BEGIN
  RETURN QUERY
    UPDATE conflicts
    SET
      title = p_title,
      description = p_description,
      favor = p_favor,
      updated_at = CURRENT_TIMESTAMP
    WHERE conflicts.id = p_id
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
