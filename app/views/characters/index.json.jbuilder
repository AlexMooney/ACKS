# frozen_string_literal: true

json.array! @characters, partial: "characters/character", as: :character
