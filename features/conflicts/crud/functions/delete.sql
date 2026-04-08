BEGIN;

DROP FUNCTION IF EXISTS conflicts_crud_delete(UUID, UUID);

CREATE FUNCTION conflicts_crud_delete(p_id UUID, p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM conflicts WHERE id = p_id AND creator_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

COMMIT;
