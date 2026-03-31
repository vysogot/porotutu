INSERT INTO couples (partner1_id, partner2_id)
SELECT u1.id, u2.id
FROM users u1, users u2
WHERE u1.email = 'one@example.com'
  AND u2.email = 'two@example.com'
ON CONFLICT DO NOTHING;
