# frozen_string_literal: true

%w[CBT Existential Psychodynamic]
  .map { |name| { name: } }
  .then { |hashes| Therapies::Therapy.create(hashes) }
