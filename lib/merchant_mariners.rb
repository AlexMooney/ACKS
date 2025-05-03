# frozen_string_literal: true

require_relative "tables"

class TradeGood
  extend Tables

  attr_reader :name, :container, :price_per_stone

  def self.random
    roll_table(CARGO_BY_ROLL)
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

class Cargo
  attr_accessor :trade_good, :quantity

  def initialize(trade_good, quantity)
    @trade_good = trade_good
    @quantity = quantity
  end

  def to_s
    "#{quantity} st of #{name} in #{container} worth #{price} gp"
  end

  def price
    (price_per_stone * quantity).round
  end

  def container
    trade_good.container
  end

  def name
    trade_good.name
  end

  def price_per_stone
    trade_good.price_per_stone
  end
end

class Gang
  include Tables

  attr_accessor :group_name, :count_dice, :leader_title, :leader_level, :extra_gang

  def initialize(group_name, count_dice, leader_title, leader_level, &extra_gang)
    @group_name = group_name
    @count_dice = count_dice
    @leader_title = leader_title
    @leader_level = leader_level
    @extra_gang = extra_gang
  end

  def roll_count
    roll_dice(count_dice)
  end

  def generate_leader!
    Character.new(leader_level, leader_title)
  end

  def attempt_extra_gang!(count, characters_by_count, leaders)
    return 0 unless extra_gang

    gang = extra_gang.call
    return 0 unless gang

    group_count = gang.roll_count
    if group_count + 1 >= count
      characters_by_count[gang.group_name] += group_count
      characters_by_count[gang.leader_title] += 1
      leaders << generate_leader!
      group_count + 1
    else
      0
    end
  end
end

class Passengers
  include Tables

  attr_accessor :characters_by_count

  def initialize(count)
    @characters_by_count = Hash.new(0)
    @leaders = []
    assign_characters!(count)
    @leaders.sort!
  end

  def to_s
    passenger_list = @characters_by_count.map do |type, count|
      "#{count}× #{type}"
    end.join(", ")
    leader_list = @leaders.map(&:to_s).tally.map do |leader_string, count|
      if count == 1
        leader_string
      else
        "#{count}× #{leader_string}"
      end
    end

    ["Passengers: #{passenger_list}"].concat(leader_list).join("\n")
  end

  def member
    raise NotImplementedError, "Subclasses must implement a member method"
  end

  def assign_characters!(count)
    count = assign_gang!(count, 0) while count.positive?
  end

  def assign_gang!(count, idx)
    gang = gangs[idx]

    if gang == gangs.last
      group_count = [gang.roll_count, count].min
      count -= group_count
      @characters_by_count[member] += group_count
      if count.positive?
        count -= 1
        @characters_by_count[gang.leader_title] += 1
        @leaders << gang.generate_leader!
      end
    else
      sub_gangs = gang.roll_count
      sub_gangs.times do
        count = assign_gang!(count, idx + 1)
        break if count <= 0
      end
      if count.positive?
        @characters_by_count[gang.leader_title] += 1
        @leaders << gang.generate_leader!
        count -= 1
      end
    end
    count -= gang.attempt_extra_gang!(count, @characters_by_count, @leaders) if count.positive?
    count
  end
end

class Commoners < Passengers
  def member
    "commoner"
  end

  def gangs
    @gangs ||= [
      Gang.new("Hamlet", "1d3", "steward", 3),
      Gang.new("Band", "1d6", "reeve", 2),
      Gang.new("Work-gang", "2d6", "yeoman", 1),
    ]
  end
end

class Pilgrims < Passengers
  def member
    "pilgrim"
  end

  def gangs
    @gangs ||= [
      Gang.new("Camp", "1d6", "vicar", 5) do
        if rand <= 0.33
          Gang.new("Novices", "2d4", "sister", 4) do
            Gang.new("Novice", "0", "novice", 1)
          end
        end
      end,
      Gang.new("Band", "1d6", "explorer", 2),
      Gang.new("Troupe", "1d8", "crusader", 1),
    ]
  end
end

class Marines < Passengers
  def assign_characters!(count)
    type = rand < 0.5 ? "heavy infantry" : "archer"
    @characters_by_count[type] += count
    @characters_by_count["boarding ramps"] = (count / 8.0).ceil
  end
end

class Ship
  include Tables

  attr_accessor :crew_size, :cargo, :artillery_pieces, :passenger_type, :passenger_count, :passengers, :captain

  def initialize
    assign_artillery!
    generate_captain!
  end

  PASSENGER_TYPE_BY_ROLL = {
    6 => Commoners,
    9 => Pilgrims,
    10 => Marines,
  }.freeze
  def generate_passengers!(dice_expression, multiplier = 1)
    self.passenger_count = roll_dice(dice_expression) * multiplier
    self.passenger_type = roll_table(PASSENGER_TYPE_BY_ROLL)
    self.passengers = passenger_type.new(passenger_count)
  end

  def generate_cargo!(dice_expression)
    @cargo = {}
    roll_dice(dice_expression).times do
      good = TradeGood.random
      lot = Cargo.new(good, 1000)
      if @cargo[lot.name]
        @cargo[lot.name].quantity += lot.quantity
      else
        @cargo[lot.name] = lot
      end
    end
  end

  def assign_artillery!
    @artillery_pieces = if rand < (cargo_value / 100_000.0) || passenger_type == Marines
                          artillery_capacity
                        else
                          0
                        end
  end

  def artillery_string
    if @artillery_pieces.positive?
      pieces_string = @artillery_pieces == 1 ? "piece" : "pieces"
      "#{@artillery_pieces} #{pieces_string} of #{artillery_weight} st artillery"
    else
      "No artillery"
    end
  end

  def artillery_capacity
    self.class.const_get(:ARTILLERY_CAPACITY)
  end

  def artillery_weight
    self.class.const_get(:ARTILLERY_WEIGHT)
  end

  def cargo_value
    @cargo.values.sum(&:price)
  end

  def cargo_weight
    @cargo.values.sum(&:quantity)
  end

  STONES_PER_PASSENGER = 50
  def total_weight
    cargo_weight + (artillery_weight * artillery_pieces) + (passenger_count * STONES_PER_PASSENGER)
  end

  def weight_string
    "Total weight carried: #{total_weight} st"
  end

  def generate_captain!
    self.captain = Character.new(self.class::CAPTAIN)
  end

  def stat_line
    "#{self.class::LABEL.capitalize} ship. #{self.class::STAT_LINE}"
  end

  def to_s
    cargo_list = @cargo.values.sort_by(&:price).map { |c| "  #{c}" }.join("\n")
    [stat_line,
     "#{crew_size}× crew, #{artillery_string}, #{weight_string}",
     captain,
     passengers,
     "Cargo worth #{cargo_value} gp weighing #{cargo_weight} st",
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
  STAT_LINE = "Speed: sail 240' / 96 miles, Cargo 10000 st, AC 2, 75 SHP"

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
  STAT_LINE = "Speed: sail 180' / 72 miles, Cargo 30000 st, AC 2, 200 SHP"

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
  STAT_LINE = "Speed: sail 180' / 60 miles, Cargo 50000 st, AC 2, 400 SHP"

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

class Character
  include Tables

  attr_accessor :level, :title, :magic_items_by_rarity

  def initialize(level, title = "captain")
    @level = level
    @title = title
    generate_magic_items!
  end

  def to_s
    magic_item_list = magic_items_by_rarity.filter_map do |rarity, items|
      next if items.empty?

      "  #{rarity.capitalize} magic items: " + items.map(&:to_s).sort.join(", ")
    end
    magic_item_list = nil if magic_item_list.empty?
    ["#{title} level #{level}", magic_item_list].compact.join("\n")
  end

  def <=>(other)
    lvl_cmp = other.level <=> level
    if lvl_cmp.zero?
      title_cmp = title <=> other.title
      if title_cmp.zero?
        other.magic_items_by_rarity.values.flatten.count <=> magic_items_by_rarity.values.flatten.count
      else
        title_cmp
      end
    else
      lvl_cmp
    end
  end

  COMMON_ITEMS_BY_LEVEL = {
    1 => "30%",
    2 => "90%",
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
    @magic_items_by_rarity = {}
    count_by_rarity = %i[rare uncommon common].filter_map do |rarity|
      prefix = rarity.upcase
      quantity = roll_dice(self.class.const_get("#{prefix}_ITEMS_BY_LEVEL")[level])
      next if quantity.nil? || quantity.zero?

      [rarity, quantity]
    end.to_h
    return if count_by_rarity.empty?

    @magic_items_by_rarity = TTMagicItems.new(**count_by_rarity).magic_items_by_rarity
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
      @commodore = Character.new(ship_type::CAPTAIN + 2, "Commodore")
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
      ships
    end
  end
end

if $PROGRAM_NAME == __FILE__
  merchant_mariners = MerchantMariners.new
  puts merchant_mariners
end
