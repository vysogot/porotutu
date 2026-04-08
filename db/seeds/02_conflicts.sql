INSERT INTO conflicts (creator_id, title, description, favor, status)
SELECT
  u1.id,
  'Who does the dishes',
  'We keep arguing about whose turn it is to do the dishes after dinner.',
  'The other person cooks for a week',
  'draft'
FROM users u1
WHERE u1.email = 'one@example.com'
LIMIT 1;

INSERT INTO conflicts (creator_id, title, description, favor, status)
SELECT
  u1.id,
  'Weekend plans',
  'One of us wants to stay home and rest, the other wants to go out with friends.',
  'The winner picks the next three weekends',
  'draft'
FROM users u1
WHERE u1.email = 'one@example.com'
LIMIT 1;

INSERT INTO conflicts (creator_id, title, description, favor, status)
SELECT
  u2.id,
  'Thermostat temperature',
  'We can never agree on what temperature to set the thermostat to.',
  'Loser has to wear a sweater for a month',
  'draft'
FROM users u2
WHERE u2.email = 'two@example.com'
LIMIT 1;
