BEGIN;

DROP FUNCTION IF EXISTS users_create(TEXT, TEXT);

CREATE FUNCTION users_create(p_email TEXT, p_password_digest TEXT)
RETURNS SETOF users AS $$
BEGIN
  RETURN QUERY
    INSERT INTO users (email, password_digest)
    VALUES (p_email, p_password_digest)
    RETURNING *;
END;
$$ LANGUAGE plpgsql;

COMMIT;
