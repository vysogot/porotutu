INSERT INTO conflicts (couple_id, creator_id, title, description, favor, status)
SELECT
  c.id,
  u1.id,
  'Who does the dishes',
  'We keep arguing about whose turn it is to do the dishes after dinner.',
  'The other person cooks for a week',
  'draft'
FROM couples c
JOIN users u1 ON u1.email = 'one@example.com'
WHERE c.partner1_id = u1.id OR c.partner2_id = u1.id
LIMIT 1;

INSERT INTO conflicts (couple_id, creator_id, title, description, favor, status)
SELECT
  c.id,
  u1.id,
  'Weekend plans',
  'One of us wants to stay home and rest, the other wants to go out with friends.',
  'The winner picks the next three weekends',
  'active'
FROM couples c
JOIN users u1 ON u1.email = 'one@example.com'
WHERE c.partner1_id = u1.id OR c.partner2_id = u1.id
LIMIT 1;

INSERT INTO conflicts (couple_id, creator_id, title, description, favor, status)
SELECT
  c.id,
  u2.id,
  'Thermostat temperature',
  'We can never agree on what temperature to set the thermostat to.',
  'Loser has to wear a sweater for a month',
  'pending'
FROM couples c
JOIN users u2 ON u2.email = 'two@example.com'
WHERE c.partner1_id = u2.id OR c.partner2_id = u2.id
LIMIT 1;
