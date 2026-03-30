CREATE OR REPLACE FUNCTION find_user_by_email(p_email TEXT)
RETURNS TABLE(id UUID, email VARCHAR, password_digest TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT users.id, users.email, users.password_digest
    FROM users
    WHERE users.email = p_email;
END;
$$ LANGUAGE plpgsql;
