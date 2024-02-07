# frozen_string_literal: true

class CreateHabitsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :habits do |t|
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
