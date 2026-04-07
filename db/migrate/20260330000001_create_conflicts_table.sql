DROP TABLE IF EXISTS conflicts CASCADE;

DO $$ BEGIN
  CREATE TYPE conflict_status AS ENUM (
    'draft',
    'active',
    'resolved',
    'canceled'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE conflicts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id  UUID NOT NULL REFERENCES users(id),
  title       TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  favor       TEXT,
  status      conflict_status NOT NULL DEFAULT 'draft',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
