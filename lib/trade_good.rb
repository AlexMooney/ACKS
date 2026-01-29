# frozen_string_literal: true

class TradeGood
  extend Tables

  attr_reader :name, :container, :price_per_stone

  def self.random
    roll_table(CARGO_BY_ROLL)
  end

  def self.random_precious
    roll_table(PRECIOUS_CARGO_BY_ROLL)
  end

  def initialize(name, container, price_per_stone)
    @name = name
    @container = container
    @price_per_stone = price_per_stone
  end

  GEMS_BY_ROLL = {
    3 => new("Semiprecious stones", "Boxes", 1000),
    4 => new("Gems", "Boxes", 7500),
  }.freeze
  PRECIOUS_CARGO_BY_ROLL = {
    20 => new("Monster parts", "Amphorae", 60),
    34 => new("Ivory tusks", "Wrapping", 100),
    48 => new("Rare furs", "Bundles", 100),
    62 => new("Spices", "Amphorae", 100),
    76 => new("Fine porcelain", "Crates", 100),
    90 => new("Precious metals", "Chests", 100),
    95 => new("Silk", "Rolls", 333),
    99 => new("Rare books & art", "Boxes", 333),
    100 => GEMS_BY_ROLL,
  }.freeze
  CARGO_BY_ROLL = {
    20 => new("Grain & vegetables", "Bags", 0.12),
    30 => new("Salt", "Bricks", 0.15),
    40 => new("Beer & ale", "Amphorae", 0.15),
    50 => new("Pottery", "Crates", 0.15),
    60 => new("Common wood", "Bundles", 0.17),
    70 => new("Wine & spirits", "Amphorae", 0.19),
    75 => new("Oils & sauces", "Amphorae", 0.30),
    80 => new("Preserved fish", "Amphorae", 0.45),
    84 => new("Preserved meat", "Amphorae", 1),
    87 => new("Glassware", "Crates", 1.5),
    89 => new("Rare wood", "Bundles", 2),
    91 => new("Common metal", "Chests", 2),
    92 => new("Common furs", "Bundles", 4.5),
    93 => new("Textiles", "Rolls", 7.5),
    94 => new("Dye & pigment", "Jars", 10),
    95 => new("Botanicals", "Bags", 15),
    96 => new("Clothing", "Bags", 15),
    97 => new("Tools", "Crates", 15),
    98 => new("Armor & weapons", "Crates", 22),
    100 => PRECIOUS_CARGO_BY_ROLL,
  }.freeze
end
