BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_delete(UUID);

CREATE FUNCTION conflicts_crud_delete(p_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM conflicts WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

COMMIT;
