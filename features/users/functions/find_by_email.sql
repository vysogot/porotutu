BEGIN;

DROP FUNCTION IF EXISTS users_find_by_email(TEXT);

CREATE FUNCTION users_find_by_email(p_email TEXT)
RETURNS SETOF users AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM users
    WHERE users.email = p_email;
END;
$$ LANGUAGE plpgsql;

COMMIT;
