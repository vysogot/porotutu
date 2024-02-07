# frozen_string_literal: true

class CreateTherapiesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :therapies do |t|
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
