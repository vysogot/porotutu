BEGIN;

DROP FUNCTION IF EXISTS create_user(TEXT, TEXT);

CREATE FUNCTION create_user(p_email TEXT, p_password_digest TEXT)
RETURNS TABLE(id UUID, email VARCHAR) AS $$
BEGIN
  RETURN QUERY
    INSERT INTO users (email, password_digest)
    VALUES (p_email, p_password_digest)
    RETURNING users.id, users.email;
END;
$$ LANGUAGE plpgsql;

COMMIT;
