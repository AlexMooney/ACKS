# frozen_string_literal: true

module MagicItemResolvers
  AMMO_TYPE_BY_ROLL = {
    13 => "Arrow",
    17 => "Crossbow Bolt",
    20 => "Sling Bullet",
  }.freeze
  WEAPON_TYPE_BY_ROLL = {
    6 => "Ammunition",
    9 => "Axe",
    12 => "Bludgeon",
    16 => "Bow",
    19 => "Spear",
    20 => "Other",
  }.freeze
  AXE_TYPE_BY_ROLL = {
    10 => "Battle Axe",
    16 => "Great Axe",
    20 => "Hand Axe",
  }.freeze
  BLUDGEON_TYPE_BY_ROLL = {
    1 => "Club",
    5 => "Flail",
    10 => "Mace",
    15 => "Morning Star",
    20 => "War Hammer",
  }.freeze
  BOW_TYPE_BY_ROLL = {
    2 => "Arbalest",
    7 => "Composite Bow",
    12 => "Long Bow",
    16 => "Short Bow",
    20 => "Crossbow",
  }.freeze
  OTHER_WEAPON_TYPE_BY_ROLL = {
    1 => "Bola",
    3 => "Net",
    4 => "Sap",
    14 => "Sling",
    17 => "Staff",
    18 => "Whip",
    19 => "Cestus",
    20 => "Staff-Sling",
  }.freeze
  SPEAR_TYPE_BY_ROLL = {
    3 => "Javelin",
    6 => "Lance",
    10 => "Pole Arm",
    20 => "Spear",
  }.freeze
  SWORD_TYPE_BY_ROLL = {
    2 => "Dagger",
    5 => "Short Sword",
    8 => "Sword",
    10 => "Two-Handed Sword",
  }.freeze

  MW_TYPE_BY_ROLL = {
    2 => AMMO_TYPE_BY_ROLL,
    6 => ARMOR_TYPE_BY_ROLL,
    7 => AXE_TYPE_BY_ROLL,
    8 => BLUDGEON_TYPE_BY_ROLL,
    9 => BOW_TYPE_BY_ROLL,
    10 => OTHER_WEAPON_TYPE_BY_ROLL,
    12 => "Shield",
    13 => SPEAR_TYPE_BY_ROLL,
    20 => SWORD_TYPE_BY_ROLL,
  }.freeze

  SUBTYPE_BY_WEAPON_TYPE = {
    "Ammunition" => AMMO_TYPE_BY_ROLL,
    "Axe" => AXE_TYPE_BY_ROLL,
    "Bludgeon" => BLUDGEON_TYPE_BY_ROLL,
    "Bow" => BOW_TYPE_BY_ROLL,
    "Spear" => SPEAR_TYPE_BY_ROLL,
    "Other" => OTHER_WEAPON_TYPE_BY_ROLL,
  }.freeze

  class Weapon
    include Tables

    attr_reader :plus

    def initialize(plus:)
      @plus = plus
    end

    def roll_details
      weapon_type = roll_table(WEAPON_TYPE_BY_ROLL)
      subtype_table = SUBTYPE_BY_WEAPON_TYPE[weapon_type]
      "#{roll_table(subtype_table)} +#{plus}"
    end
  end

  class MasterworkEquipment
    include Tables

    attr_reader :quality, :quantity

    def initialize(quality, quantity: "1")
      @quality = quality
      @quantity = quantity
    end

    def roll_details
      count = roll_dice(quantity)
      if count > 1
        count.times.map { MasterworkEquipment.new(quality).roll_details }.join(", ")
      else
        type = roll_table(MW_TYPE_BY_ROLL)
        quality_label = case quality
                        when :greater
                          "Masterwork"
                        when :lesser
                          if type.end_with?("Armor") || type.end_with?("Shield")
                            "Lightweight"
                          else
                            roll_table(%w[Brutal Accurate])
                          end
                        end
        "#{quality_label} #{type}"
      end
    end
  end

  class Ammunition
    include Tables

    attr_reader :plus, :quantity

    def initialize(plus:, quantity:)
      @plus = plus
      @quantity = quantity
    end

    def roll_details
      "#{roll_dice(quantity)}x #{roll_table(AMMO_TYPE_BY_ROLL)} +#{plus}"
    end
  end
end
