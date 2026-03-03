# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 20_260_303_194_333) do
  create_table "characters", force: :cascade do |t|
    t.string "alignment"
    t.string "build"
    t.integer "cha"
    t.string "character_class"
    t.string "class_type"
    t.integer "con"
    t.datetime "created_at", null: false
    t.integer "dex"
    t.string "ethnicity"
    t.string "eye_color"
    t.text "features"
    t.string "hair_color"
    t.string "hair_texture"
    t.integer "height_inches"
    t.integer "int"
    t.integer "level"
    t.string "name"
    t.string "sex"
    t.string "skin_color"
    t.integer "str"
    t.integer "template"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "weight_lbs"
    t.integer "wil"
  end
end
