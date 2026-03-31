BEGIN;

DROP FUNCTION IF EXISTS get_couple_for_user(UUID);

CREATE FUNCTION get_couple_for_user(p_user_id UUID)
RETURNS TABLE(id UUID, partner1_id UUID, partner2_id UUID, disconnected_partner_id UUID) AS $$
BEGIN
  RETURN QUERY
    SELECT
      couples.id,
      couples.partner1_id,
      couples.partner2_id,
      couples.disconnected_partner_id
    FROM couples
    WHERE couples.partner1_id = p_user_id
       OR couples.partner2_id = p_user_id
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMIT;
