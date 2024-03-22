# frozen_string_literal: true

CREATURE_BY_ROLL = ["Angels", "Animals", "Beastment", "Constructs",
                    "Demons", "Dragons", "Dwarves, Gnomes, & Halflings", "Elementals",
                    "Elves, Faeries, & Fey", "Giants", "Humans", "Lycanthropes",
                    "Oozes", "Plants", "Regenerating Creatures", "Sea Creatures",
                    "Spellcasters", "Undead", "Vermin", "Roll Twice"].freeze
class ScrollCreatureWarding
  include Tables

  def roll_details
    creature = roll_table(CREATURE_BY_ROLL)
    while creature.match?(/Roll Twice/)
      creature = creature.sub("Roll Twice", "#{roll_table(CREATURE_BY_ROLL)} & #{roll_table(CREATURE_BY_ROLL)}")
    end
    "Scroll of Warding vs. #{creature}"
  end
end

AMMO_TYPE_BY_ROLL = {
  13 => "Arrow",
  17 => "Crossbow Bolt",
  20 => "Sling Bullet",
}.freeze
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
      count.times.map { MasterworkEquipment.new(quality).roll_details }.join("\n")
    else
      type = roll_table(MW_TYPE_BY_ROLL)
      quality_label = case quality
                      when :greater
                        "Masterwork"
                      when :lesser
                        if type.end_with?("Armor")
                          "Lightweight"
                        else
                          roll_table(%w[Brutal Accurate])
                        end
                      end
      "#{quality_label} #{type}"
    end
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

class SpellScroll
  include Tables

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
    flavor = roll_table(%w[Eldritch Divine]) if language == "Dwarven" && flavor == "Arcane"

    remaining_levels = levels
    spells = []
    while remaining_levels.positive?
      level = rand(1..[remaining_levels, 6].min)
      remaining_levels -= level
      spells << level
    end
    "#{flavor} Scroll in #{language} with #{spells.sort.join(', ')} level spells"
  end
end
