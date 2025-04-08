# frozen_string_literal: true

require_relative "tables"
require_relative "random_magic_items"

class Cargo
  extend Tables

  attr_accessor :name, :container, :price_per_stone, :quantity

  def self.random
    new(*roll_table(CARGO_BY_ROLL), 1000)
  end

  def initialize(name, container, price_per_stone, quantity)
    @name = name
    @container = container
    @price_per_stone = price_per_stone
    @quantity = quantity
  end

  def price
    (@price_per_stone * quantity).round
  end

  def to_s
    "#{quantity} St of #{name} in #{container} worth #{price} gp"
  end

  GEMS_BY_ROLL = {
    3 => ["Semiprecious stones", "Boxes", 1000],
    4 => ["Gems", "Boxes", 7500],
  }.freeze
  PRECIOUS_CARGO_BY_ROLL = {
    20 => ["Monster parts", "Amphorae", 60],
    34 => ["Ivory tusks", "Wrapping", 100],
    48 => ["Rare furs", "Bundles", 100],
    62 => ["Spices", "Amphorae", 100],
    76 => ["Fine porcelain", "Crates", 100],
    90 => ["Precious metals", "Chests", 100],
    95 => ["Silk", "Rolls", 333],
    99 => ["Rare books & art", "Boxes", 333],
    100 => GEMS_BY_ROLL,
  }.freeze
  CARGO_BY_ROLL = {
    20 => ["Grain & vegetables", "Bags", 0.12],
    30 => ["Salt", "Bricks", 0.15],
    40 => ["Beer & ale", "Amphorae", 0.15],
    50 => ["Pottery", "Crates", 0.15],
    60 => ["Common wood", "Bundles", 0.17],
    70 => ["Wine & spirits", "Amphorae", 0.19],
    75 => ["Oils & sauces", "Amphorae", 0.30],
    80 => ["Preserved fish", "Amphorae", 0.45],
    84 => ["Preserved meat", "Amphorae", 1],
    87 => ["Glassware", "Crates", 1.5],
    89 => ["Rare wood", "Bundles", 2],
    91 => ["Common metal", "Chests", 2],
    92 => ["Common furs", "Bundles", 4.5],
    93 => ["Textiles", "Rolls", 7.5],
    94 => ["Dye & pigment", "Jars", 10],
    95 => ["Botanicals", "Bags", 15],
    96 => ["Clothing", "Bags", 15],
    97 => ["Tools", "Crates", 15],
    98 => ["Armor & weapons", "Crates", 22],
    100 => PRECIOUS_CARGO_BY_ROLL,
  }.freeze
end

class Ship
  include Tables

  attr_accessor :crew_size, :cargo, :artillery_string, :passenger_type, :passenger_count, :captain

  def initialize
    assign_artillery!
    generate_captain!
  end

  PASSENGER_TYPE_BY_ROLL = {
    6 => "Commoners",
    9 => "Pilgrims",
    10 => "Marines",
  }.freeze
  def generate_passengers!(dice_expression, multiplier = 1)
    self.passenger_count = roll_dice(dice_expression) * multiplier
    self.passenger_type = roll_table(PASSENGER_TYPE_BY_ROLL)
  end

  def generate_cargo!(dice_expression)
    @cargo = {}
    roll_dice(dice_expression).times do
      lot = Cargo.random
      if @cargo[lot.name]
        @cargo[lot.name].quantity += lot.quantity
      else
        @cargo[lot.name] = lot
      end
    end
  end

  def assign_artillery!
    artillery_pieces = if rand < (cargo_value / 100_000.0) || passenger_type == "Marines"
                         artillery_capacity
                       else
                         0
                       end
    if artillery_pieces.positive?
      pieces_string = artillery_pieces == 1 ? "piece" : "pieces"
      self.artillery_string = "#{artillery_pieces} #{pieces_string} of #{artillery_weight} artillery"
    else
      self.artillery_string = "No artillery"
    end
  end

  def artillery_capacity
    self.class.const_get(:ARTILLERY_CAPACITY)
  end

  def artillery_weight
    "#{self.class.const_get(:ARTILLERY_WEIGHT)} st"
  end

  def cargo_value
    @cargo.values.sum(&:price)
  end

  def generate_captain!
    self.captain = Captain.new(self.class::CAPTAIN)
  end

  def stat_line
    "#{self.class::LABEL.capitalize} ship. #{self.class::STAT_LINE}"
  end

  def to_s
    cargo_list = @cargo.values.sort_by(&:price).map { |c| "  #{c}" }.join("\n")
    [stat_line,
     "#{crew_size} crew, #{passenger_count} #{passenger_type}, #{artillery_string}",
     captain,
     "Cargo worth #{cargo_value} gp",
     cargo_list,
     ""].join("\n")
  end
end

class SmallShip < Ship
  FLEET_SIZE = "1d12"
  CAPTAIN = 1
  ARTILLERY_CAPACITY = 1
  ARTILLERY_WEIGHT = 400
  LABEL = "small"
  STAT_LINE = "Speed: sail 240' / 96 miles, Cargo 10,000 st, AC 2, 75 SHP"

  def initialize
    self.crew_size = 10 # 20 40
    generate_passengers!("6d10") # 2d8*10 4d6*10
    generate_cargo!("3d4") # 6d6 7d10
    super
  end
end

class LargeShip < Ship
  FLEET_SIZE = "1d6"
  CAPTAIN = 4
  ARTILLERY_CAPACITY = 4
  ARTILLERY_WEIGHT = 800
  LABEL = "large"
  STAT_LINE = "Speed: sail 180' / 72 miles, Cargo 30,000 st, AC 2, 200 SHP"

  def initialize
    self.crew_size = 20
    generate_passengers!("2d8", 10)
    generate_cargo!("6d6")
    super
  end

  def artillery_capacity
    ARTILLERY_CAPACITY
  end
end

class HugeShip < Ship
  FLEET_SIZE = "1d3"
  CAPTAIN = 5
  ARTILLERY_CAPACITY = 8
  ARTILLERY_WEIGHT = 800
  LABEL = "huge"
  STAT_LINE = "Speed: sail 180' / 60 miles, Cargo 50,000 st, AC 2, 400 SHP"

  def initialize
    self.crew_size = 40
    generate_passengers!("4d6", 10)
    generate_cargo!("7d10")
    super
  end

  def artillery_capacity
    ARTILLERY_CAPACITY
  end
end

class Captain
  include Tables

  attr_accessor :level, :title, :magic_items_by_rarity

  def initialize(level, title = "Captain")
    @level = level
    @title = title
    @magic_items_by_rarity = { "common" => [], "uncommon" => [], "rare" => [] }
    generate_magic_items!
  end

  def to_s
    magic_item_list = magic_items_by_rarity.filter_map do |rarity, items|
      next if items.empty?

      "  #{rarity.capitalize} magic items: " + items.map(&:to_s).sort.join(", ")
    end
    ["#{title} level #{level}",
     magic_item_list].join("\n")
  end

  COMMON_ITEMS_BY_LEVEL = {
    1 => "30%",
    3 => 1,
    4 => "1d4-1",
    5 => 2,
    6 => 4,
    7 => 4,
  }.freeze
  UNCOMMON_ITEMS_BY_LEVEL = {
    3 => "15%",
    4 => "40%",
    5 => 1,
    6 => 2,
    7 => 2,
  }.freeze
  RARE_ITEMS_BY_LEVEL = {
    7 => "66%",
  }.freeze
  def generate_magic_items!
    %w[rare uncommon common].each do |rarity|
      prefix = rarity.upcase
      quantity = roll_dice(self.class.const_get("#{prefix}_ITEMS_BY_LEVEL")[level])
      next if quantity.nil? || quantity.zero?

      magic_items_by_rarity[rarity] = RandomMagicItems.new.magic_items(rarity, quantity)
    end
  end
end

class MerchantMariners
  include Tables
  attr_accessor :number_of_ships, :ship_type, :ships, :commodore

  SHIP_TYPES_BY_ROLL = {
    5 => SmallShip,
    8 => LargeShip,
    10 => HugeShip,
  }.freeze
  LAIR_CHANCE = 0.25
  def initialize
    @ship_type = roll_table(SHIP_TYPES_BY_ROLL)

    if rand < LAIR_CHANCE
      @number_of_ships = roll_dice(ship_type::FLEET_SIZE)
      @commodore = Captain.new(ship_type::CAPTAIN + 2, "Commodore")
    else
      @number_of_ships = 1
      @commodore = nil
    end

    @ships = []
    @number_of_ships.times do
      @ships << @ship_type.new
    end
  end

  def to_s
    ships = @ships.map(&:to_s).join("\n")
    if @commodore
      "Fleet of #{@number_of_ships} #{@ship_type::LABEL} ships\n#{@commodore}\n\n#{ships}"
    else
      "A single #{@ship_type::LABEL} ship\n#{ships}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  merchant_mariners = MerchantMariners.new
  puts merchant_mariners
end
