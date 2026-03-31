CREATE TABLE IF NOT EXISTS couples (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner1_id             UUID NOT NULL REFERENCES users(id),
  partner2_id             UUID NOT NULL REFERENCES users(id),
  disconnected_partner_id UUID,
  created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
