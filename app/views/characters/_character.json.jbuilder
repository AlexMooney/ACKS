# frozen_string_literal: true

json.extract! character, :id, :name, :title, :level, :character_class, :class_type, :template, :ethnicity, :sex,
              :alignment, :str, :int, :wil, :dex, :con, :cha, :build, :height_inches, :weight_lbs, :eye_color, :skin_color, :hair_color, :hair_texture, :features, :created_at, :updated_at
json.url character_url(character, format: :json)
