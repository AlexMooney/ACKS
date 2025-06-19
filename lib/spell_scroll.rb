# frozen_string_literal: true

class SpellScroll
  include Tables
  include SpellLists

  attr_reader :levels

  def initialize(levels)
    @levels = levels
  end

  LANGUAGE_BY_ROLL = {
    20 => "Classical Auran",
    30 => "Common",
    50 => "Draconic",
    70 => "Dwarven",
    90 => "Elven",
    100 => "Zaharan",
  }.freeze
  def roll_details
    flavor = roll_table(%w[Arcane Divine])
    language = roll_table(LANGUAGE_BY_ROLL)
    flavor = roll_table(%w[Gnostic Divine]) if language == "Dwarven" && flavor == "Arcane"

    remaining_levels = levels
    spell_levels = []
    while remaining_levels.positive?
      level = rand(1..[remaining_levels, 6].min)
      remaining_levels -= level
      spell_levels << level
    end
    spell_names = spell_levels.sort.map do |level|
      spell = self.class.const_get("#{flavor.upcase}_BY_LEVEL")[level].sample
      spell = spell.sub("*", (rand(3).zero? ? " Reversed" : ""))
      "#{spell} (#{level})"
    end
    "#{flavor} Scroll in #{language} with #{spell_names.join(', ')}"
  end
end
