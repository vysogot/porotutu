DROP TABLE IF EXISTS conflicts CASCADE;

DO $$ BEGIN
  CREATE TYPE conflict_status AS ENUM (
    'draft', 'pending', 'active',
    'resolved', 'postponed', 'favor_done', 'canceled'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE conflicts (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id        UUID NOT NULL REFERENCES couples(id),
  creator_id       UUID NOT NULL REFERENCES users(id),
  title            TEXT NOT NULL,
  description      TEXT NOT NULL DEFAULT '',
  favor            TEXT,
  status           conflict_status NOT NULL DEFAULT 'draft',
  deadline         TIMESTAMP,
  recur_count      INTEGER NOT NULL DEFAULT 0,
  proposed_status  TEXT,
  proposed_by_id   UUID REFERENCES users(id),
  notified_overdue INTEGER NOT NULL DEFAULT 0,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  archived_at      TIMESTAMP
);
