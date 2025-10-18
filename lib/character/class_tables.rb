# frozen_string_literal: true

class Character
  module ClassTables
    CLASS_TYPE = {
      10 => "mage",
      30 => "thief",
      50 => "crusader",
      75 => "fighter",
      90 => "explorer",
      100 => "venturer",
    }.freeze

    CLASS_BY_TYPE = {
      "mage" => {
        90 => "Mage",
        94 => "Elven Spellsword",
        98 => "Warlock",
        100 => "Nobiran Wonderworker",
      },
      "thief" => {
        40 => "Thief",
        60 => "Bard",
        80 => "Assassin",
        90 => "Thief",
        94 => "Elven Nightblade",
        100 => "Thief Special",
      },
      "crusader" => {
        40 => "Crusader",
        60 => "Bladedancer",
        80 => "Priestess",
        90 => "Shaman",
        94 => "Dwarven Craftpriest",
        98 => "Witch",
        100 => "Crusader Special",
      },
      "fighter" => {
        80 => "Fighter",
        90 => "Barbarian",
        94 => "Dwarven Vaultguard",
        98 => "Paladin",
        100 => "Zaharan Ruinguard",
      },
      "explorer" => {
        90 => "Explorer",
        100 => "Explorer Special",
      },
      "venturer" => {
        90 => "Venturer",
        100 => "Venturer Special",
      },
    }.freeze

    SEX_BY_CLASS = Hash.new do |hash, class_type|
      hash[class_type] = %w[male female]
    end
    SEX_BY_CLASS["Crusader"] = %w[male male female]
    SEX_BY_CLASS["Bladedancer"] = %w[female]
    SEX_BY_CLASS["Priestess"] = %w[female]
    SEX_BY_CLASS["Shaman"] = %w[female female male]
    SEX_BY_CLASS["Dwarven Craftpriest"] = %w[male]
    SEX_BY_CLASS["Witch"] = %w[female]
    SEX_BY_CLASS["Fighter"] = %w[male male male female]
    SEX_BY_CLASS["Barbarian"] = %w[male male female]
    SEX_BY_CLASS["Dwarven Vaultguard"] = %w[male]
    SEX_BY_CLASS["Paladin"] = %w[male male male female]
    SEX_BY_CLASS["Explorer"] = %w[male male female]

    ALIGNMENT = {
      2 => "Lawful",
      5 => "Neutral",
      6 => "Chaotic",
    }.freeze

    BASE_LEVEL = {
      1 => "Base - 2",
      2 => "Base - 1",
      4 => "Base",
      5 => "Base + 1",
      6 => "Base + 2",
    }.freeze

    StatPreference = Struct.new(:best, :always_good, :never_good, keyword_init: true)
    STAT_PREFERENCE_BY_CLASS = {
      "Elven Spellsword" => StatPreference.new(best: "INT", always_good: %w[DEX STR]),
      "Nobiran Wonderworker" => StatPreference.new(best: "INT", always_good: %w[WIL]),

      "Bard" => StatPreference.new(best: "CHA", always_good: %w[DEX]),
      "Assassin" => StatPreference.new(best: "DEX", always_good: %w[STR]),
      "Elven Nightblade" => StatPreference.new(best: "DEX", always_good: %w[INT]),

      "Bladedancer" => StatPreference.new(best: "DEX", always_good: %w[WIL CHA]),
      "Priestess" => StatPreference.new(best: "WIL", always_good: %w[CHA], never_good: %w[STR]),
      "Dwarven Craftpriest" => StatPreference.new(best: "WIL", always_good: %w[CON]),
      "Witch" => StatPreference.new(best: "INT", always_good: %w[WIL], never_good: %w[STR]),

      "Zaharan Ruinguard" => StatPreference.new(best: "STR", always_good: %w[INT WIL]),
    }.freeze

    STAT_PREFERENCE_BY_CLASS_TYPE = {
      "mage" => StatPreference.new(best: "INT", never_good: %w[STR]),
      "thief" => StatPreference.new(best: "DEX", never_good: %w[WIL]),
      "crusader" => StatPreference.new(best: "WIL", never_good: %w[]),
      "fighter" => StatPreference.new(best: "STR", always_good: %w[CON DEX]),
      "explorer" => StatPreference.new(best: "CON", always_good: %w[DEX]),
      "venturer" => StatPreference.new(best: "CHA", always_good: %w[INT]),
      "normal_man" => StatPreference.new(best: nil, never_good: %w[STR INT WIL DEX CON CHA]),
    }.freeze
  end
end
