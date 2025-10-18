# frozen_string_literal: true

require_relative "tables"


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

# TODO: switch to Monster::Gang
class Gang
  include Tables

  attr_accessor :group_name, :count_dice, :leader_title, :leader_level, :leader_class, :extra_gang

  def initialize(group_name, count_dice, leader_title, leader_level, leader_class, &extra_gang)
    @group_name = group_name
    @count_dice = count_dice
    @leader_title = leader_title
    @leader_level = leader_level
    @leader_class = leader_class
    @extra_gang = extra_gang
  end

  def roll_count
    roll_dice(count_dice)
  end

  def generate_leader!(ethnicity:)
    Character.new(leader_level, leader_title, character_class: leader_class, ethnicity:)
  end

  def attempt_extra_gang!(characters_by_count, leaders, max_count = nil, ethnicity:)
    return 0 unless extra_gang

    gang = extra_gang.call
    return 0 unless gang

    group_count = gang.roll_count
    if max_count.nil? || group_count + 1 <= max_count
      characters_by_count[gang.group_name] += group_count
      characters_by_count[gang.leader_title] += 1
      leaders << generate_leader!(ethnicity:)
      group_count + 1
    else
      0
    end
  end
end

class Passengers
  include Tables

  attr_accessor :characters_by_count, :ethnicity

  def initialize(count, ethnicity:)
    @characters_by_count = Hash.new(0)
    @ethnicity = ethnicity
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
        @leaders << gang.generate_leader!(ethnicity:)
      end
    else
      sub_gangs = gang.roll_count
      sub_gangs.times do
        count = assign_gang!(count, idx + 1)
        break if count <= 0
      end
      if count.positive?
        @characters_by_count[gang.leader_title] += 1
        @leaders << gang.generate_leader!(ethnicity:)
        count -= 1
      end
    end
    count -= gang.attempt_extra_gang!(@characters_by_count, @leaders, count, ethnicity:) if count.positive?
    count
  end
end

class Commoners < Passengers
  def member
    "commoner"
  end

  def gangs
    @gangs ||= [
      Gang.new("Hamlet", "1d3", "Steward", 3, "Fighter"),
      Gang.new("Band", "1d6", "Reeve", 2, "Fighter"),
      Gang.new("Work-gang", "2d6", "Yeoman", 1, "Fighter"),
    ]
  end
end

class Pilgrims < Passengers
  def member
    "pilgrim"
  end

  def gangs
    @gangs ||= [
      Gang.new("Camp", "1d6", "Vicar", 5, "Crusader") do
        if rand <= 0.33
          Gang.new("Novices", "2d4", "Sister", 4, "Priestess") do
            Gang.new("Novice", "0", "Novice", 1, "Priestess")
          end
        end
      end,
      Gang.new("Band", "1d6", nil, 2, "Explorer"),
      Gang.new("Troupe", "1d8", nil, 1, "Crusader"),
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

class MerchantMariners
  include Tables
  attr_accessor :number_of_ships, :ship_type, :ships, :commodore, :flag

  SHIP_TYPES_BY_ROLL = {
    5 => Ship::SmallShip,
    8 => Ship::LargeShip,
    10 => Ship::HugeShip,
  }.freeze
  LAIR_CHANCE = 0.25
  def initialize(flag: nil)
    @flag = flag || roll_table(Ship::RANDOM_FLAG_SYRNASOS)
    @ship_type = roll_table(SHIP_TYPES_BY_ROLL)

    if rand < LAIR_CHANCE
      @number_of_ships = roll_dice(ship_type::FLEET_SIZE)
      @commodore = Character.new(ship_type::CAPTAIN + 2,
                                 "Commodore",
                                 character_class: roll_table(captain_class_table),
                                 ethnicity: @flag.downcase)
    else
      @number_of_ships = 1
      @commodore = nil
    end

    @ships = []
    @number_of_ships.times do
      @ships << @ship_type.new(flag: @flag)
    end
  end

  def captain_class_table
    Ship::ShipTables::MERCHANT_CAPTAIN_CLASS_TABLE
  end

  def to_s
    if @commodore
      "#{flag} fleet of #{@number_of_ships} #{@ship_type::LABEL} ships\n#{@commodore}\n\n#{ships.map(&:to_s).join("\n")}"
    else
      "#{flag} #{ships.first.ship_class}\n#{ships.first}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  merchant_mariners = MerchantMariners.new
  puts merchant_mariners
end
