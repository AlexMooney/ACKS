# frozen_string_literal: true

module MagicItemResolvers
  ARMOR_TYPE_BY_ROLL = {
    5 => "Leather Armor",
    6 => "Light Arena Armor",
    7 => "Ring Armor",
    8 => "Scale Armor",
    12 => "Chain Armor",
    13 => "Heavy Arena Armor",
    14 => "Banded Plate Armor",
    15 => "Lamellar Armor",
    20 => "Plate Armor",
  }.freeze

  require_relative "magic_item_resolvers/weapons"

  class Armor
    include Tables

    attr_reader :plus

    def initialize(plus:)
      @plus = plus
    end

    def roll_details
      type = roll_table(ARMOR_TYPE_BY_ROLL)
      "#{type} +#{plus}"
    end
  end

  class PotionOfEnergyProtection
    include Tables

    DAMAGE_TYPE_BY_ROLL = {
      1 => "acidic",
      2 => "poisonous",
      4 => "bludgeoning",
      6 => "piercing",
      8 => "slashing",
    }.freeze

    def roll_details
      "Potion of #{roll_table(DAMAGE_TYPE_BY_ROLL)} protection"
    end
  end

  class PotionOfPhysicalProtection
    include Tables

    DAMAGE_TYPE_BY_ROLL = {
      2 => "cold",
      3 => "electrical",
      5 => "fire",
      6 => "luminous",
      7 => "necrotic",
      8 => "seismic",
    }.freeze

    def roll_details
      "Potion of #{roll_table(DAMAGE_TYPE_BY_ROLL)} protection"
    end
  end
end
