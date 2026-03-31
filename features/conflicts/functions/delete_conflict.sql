BEGIN;

DROP FUNCTION IF EXISTS delete_conflict(UUID);

CREATE FUNCTION delete_conflict(p_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM conflicts WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

COMMIT;
