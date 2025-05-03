# frozen_string_literal: true

module Encounters
  class RandomEncounter
    include Tables

    DANGER_LEVELS = %w[road_only Civilized Borderlands Outlands Unsettled].freeze
    MONSTER_RARITY_BY_DANGER_LEVEL = {
      1 => {
        14 => "common",
        19 => "uncommon",
        20 => "rare",
      },
      2 => {
        12 => "common",
        18 => "uncommon",
        20 => "rare",
      },
      3 => {
        10 => "common",
        15 => "uncommon",
        19 => "rare",
        20 => "very_rare",
      },
      4 => {
        8 => "common",
        14 => "uncommon",
        18 => "rare",
        20 => "very_rare",
      },
    }.freeze

    attr_reader :raw_danger_level, :danger_level, :danger_label, :result

    def initialize(danger_level_string)
      @danger_level = @raw_danger_level = danger_level_string.to_i
      raise "Invalid danger level: #{danger_level}. Valid values are 1-4." unless (1..4).include?(danger_level)

      @danger_label = DANGER_LEVELS[danger_level]
    end

    def roll_encounter_type
      danger_upgrades = ""
      roll = rand(1..20)
      while roll == 1 && danger_level < 4
        danger_upgrades += "+"
        @danger_level += 1
        roll = rand(1..20)
      end

      encounter_type = roll_table(encounter_type_by_danger_level.fetch(danger_level), roll)
      encounter_type += " (danger #{danger_upgrades})" unless danger_upgrades.empty?
      encounter_type
    end

    def monster_rarity
      @monster_rarity ||= roll_table(MONSTER_RARITY_BY_DANGER_LEVEL[raw_danger_level])
    end

    def csv_encounter(csv_name, column_label)
      roll_table(self.class.encounter_table_by_column(csv_name, column_label))
    end

    def self.encounter_table_by_column(csv_name)
      @encounter_table_by_column ||= {}
      @table_by_csv_name[csv_name] ||= begin
                                         CSV.parse(File.read(File.expand_path("encounters/#{csv_name}.csv", __dir__)), headers: true)
                                       end
    end
  end
end
