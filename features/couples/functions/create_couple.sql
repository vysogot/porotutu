CREATE OR REPLACE FUNCTION create_couple(p_partner1_id UUID, p_partner2_id UUID)
RETURNS TABLE(id UUID, partner1_id UUID, partner2_id UUID, disconnected_partner_id UUID) AS $$
BEGIN
  RETURN QUERY
    INSERT INTO couples (partner1_id, partner2_id)
    VALUES (p_partner1_id, p_partner2_id)
    RETURNING
      couples.id,
      couples.partner1_id,
      couples.partner2_id,
      couples.disconnected_partner_id;
END;
$$ LANGUAGE plpgsql;
