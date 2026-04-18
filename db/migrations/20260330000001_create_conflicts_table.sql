DROP TABLE IF EXISTS conflicts CASCADE;

CREATE TABLE conflicts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id  UUID NOT NULL REFERENCES users(id),
  title       TEXT NOT NULL,
  description TEXT,
  favor       TEXT,
  status      TEXT,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
