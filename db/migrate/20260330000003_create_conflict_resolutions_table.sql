CREATE TABLE IF NOT EXISTS conflict_resolutions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conflict_id UUID NOT NULL REFERENCES conflicts(id) ON DELETE CASCADE,
  status      TEXT NOT NULL,
  favor       TEXT,
  resolved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
