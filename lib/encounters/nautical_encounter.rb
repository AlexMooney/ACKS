# frozen_string_literal: true

module Encounters
  class NauticalEncounter < RandomEncounter
    ENCOUNTER_TYPE_BY_DANGER_LEVEL = {
      0 => {
        13 => "No Encounter",
        20 => "Civilized Encounter",
      }.freeze,
      1 => {
        12 => "No Encounter",
        18 => "Civilized Encounter",
        19 => "Monster Encounter",
        20 => "Nautical Encounter",
      }.freeze,
      2 => {
        12 => "No Encounter",
        16 => "Civilized Encounter",
        19 => "Monster Encounter",
        20 => "Nautical Encounter",
      }.freeze,
      3 => {
        11 => "No Encounter",
        14 => "Civilized Encounter",
        18 => "Monster Encounter",
        20 => "Nautical Encounter",
      }.freeze,
      4 => {
        10 => "No Encounter",
        17 => "Monster Encounter",
        20 => "Nautical Encounter",
      }.freeze,
    }.freeze
    NAUTICAL_ENCOUNTER_BY_ROLL = {
      5 => { # beneficial
        1 => "Castaway",
        2 => "Derelict",
        3 => "Favorable Current",
        4 => "Favorable Winds",
        5 => "Flotsam",
        6 => "Good Omen",
        7 => "Monster Carcass",
        8 => "Nagivational Sign",
        9 => "Plentiful Fish",
        10 => "Safe Haven",
        11 => "Smooth Sailing",
        12 => "Double",
      }.freeze,
      10 => { # detrimental
        1 => "Bad Omen",
        2 => "Dead Sea",
        3 => "Food Spoilage",
        4 => "Mariner Overboard",
        5 => "Nautical Challenge",
        6 => "Nautical Hazard",
        7 => "Rogue Wave",
        8 => "Rough Conditions",
        9 => "Unpredictable Weather",
        10 => "Water Spoilage",
        11 => "Wear-and-Tear",
        12 => "Double",
      }.freeze,
      12 => { # unique
        1 => "Colossal Statue",
        2 => "Damned Mariners",
        3 => "Deafening Mist",
        4 => "Ghost Ship",
        5 => "Leviathan",
        6 => "Magical Resource",
        7 => "Marine Formation",
        8 => "Message in a Bottle",
        9 => "Place of Power",
        10 => "Sunken Treasure Ship",
        11 => "Truly Unique",
        12 => "Double",
      }.freeze,
    }.freeze

    def initialize(danger_level_string, trade_route: false)
      super(danger_level_string)

      if trade_route && trade_route != "false" && trade_route != "0"
        @danger_level -= 1
        @danger_label += " with Trade Route"
      end

      encounter_type = roll_encounter_type
      @result = case encounter_type
                when /Civilized Encounter/
                  civilization_sub_table = DANGER_LEVELS[raw_danger_level].downcase
                  "#{encounter_type}: #{Terrain.new('sea_civilized').random_monster(civilization_sub_table)}"
                when /Monster Encounter/
                  "#{encounter_type} (#{monster_rarity}): #{Terrain.new('sea_monster').random_monster(monster_rarity)}"
                when /Nautical Encounter/
                  type_roll = rand(1..12)
                  nautical = roll_table(NAUTICAL_ENCOUNTER_BY_ROLL, type_roll)
                  while nautical.match?(/Double/)
                    first = roll_table(NAUTICAL_ENCOUNTER_BY_ROLL, type_roll)
                    second = roll_table(NAUTICAL_ENCOUNTER_BY_ROLL, type_roll)
                    nautical = nautical.sub("Double", "#{first} & #{second}")
                  end
                  "#{encounter_type}: #{nautical}"
                else
                  encounter_type
                end
    end

    def to_s
      "- [ ] #{result}"
    end

    private

    def encounter_type_by_danger_level
      ENCOUNTER_TYPE_BY_DANGER_LEVEL
    end
  end
end
