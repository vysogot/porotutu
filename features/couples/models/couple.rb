# frozen_string_literal: true

module Couples
  Couple = Data.define(:id, :partner1_id, :partner2_id, :disconnected_partner_id)
end
