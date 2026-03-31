INSERT INTO users (email, password_digest)
VALUES
  -- The password is: pass
  ('one@example.com', '$2a$12$HUnZfyA1ShsvKbmxiPtnQutkVJxkBcmtZWWmLsR.7uzu1drnWQDYq'),
  ('two@example.com', '$2a$12$HUnZfyA1ShsvKbmxiPtnQutkVJxkBcmtZWWmLsR.7uzu1drnWQDYq')
ON CONFLICT (email) DO NOTHING;
