# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "pry"
  gem "thor", "~> 1.2.1"
end

require_relative "tables"
require_relative "magic_items"

class RandomMagicItems < Thor
  include Tables

  COMMON_ITEM_BY_ROLL = {
    5 => Ammunition.new(plus: 1, quantity: "1"),
    6 => MasterworkEquipment.new(:greater),
    25 => MasterworkEquipment.new(:lesser, quantity: "1d4"),
    26 => "Healing Salve",
    27 => "Oil of Ooze",
    30 => "Oil of Sharpness",
    31 => "Oil of Slickness",
    32 => "Potion of Adjust Self",
    34 => "Potion of Allure",
    35 => "Potion of Arcane Armor",
    41 => "Potion of Cure Light Injury",
    42 => "Potion of Cure Moderate Injury",
    43 => "Potion of Delay Disease",
    44 => "Potion of Delay Poison",
    45 => "Potion of Discern Evil",
    46 => "Potion of Discern Invisible",
    47 => "Potion of Discern Magic",
    48 => "Potion of Divine Armor",
    50 => PotionOfEnergyProtection.new,
    51 => "Potion of Hallucination",
    52 => "Potion of Leaping",
    53 => "Potion of Levitation",
    54 => "Potion of Locate Object",
    55 => "Potion of Ogre Strength",
    57 => PotionOfPhysicalProtection.new,
    58 => "Potion of Shimmer",
    59 => "Potion of Spider Climbing",
    60 => "Potion of Swift Sword",
    61 => "Potion of Swimming",
    71 => ScrollCreatureWarding.new,
    91 => SpellScroll.new(1),
    98 => SpellScroll.new(2),
    100 => "Treasure Map (Treasure Type B)",
  }.freeze
  TABLE_BY_QUALITY = {
    "common" => COMMON_ITEM_BY_ROLL,
  }.freeze
  desc "magic_items QUALITY QUANTITY=1", "Generate magic items"
  def magic_items(quality, quantity = 1)
    table = TABLE_BY_QUALITY[quality]
    magic_items = quantity.to_i.times.map do
      roll_table(table)
    end
    magic_items.map! do |item|
      case item
      when String
        item
      else
        item.roll_details
      end
    end
    puts magic_items.sort
  end
end

RandomMagicItems.start(ARGV) if __FILE__ == $PROGRAM_NAME
