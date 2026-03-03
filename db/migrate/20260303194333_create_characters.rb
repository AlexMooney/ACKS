# frozen_string_literal: true

class CreateCharacters < ActiveRecord::Migration[8.1]
  def change
    create_table :characters do |t|
      t.string :name
      t.string :title
      t.integer :level
      t.string :character_class
      t.string :class_type
      t.integer :template
      t.string :ethnicity
      t.string :sex
      t.string :alignment
      t.integer :str
      t.integer :int
      t.integer :wil
      t.integer :dex
      t.integer :con
      t.integer :cha
      t.string :build
      t.integer :height_inches
      t.integer :weight_lbs
      t.string :eye_color
      t.string :skin_color
      t.string :hair_color
      t.string :hair_texture
      t.text :features

      t.timestamps
    end
  end
end
