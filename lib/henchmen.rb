# frozen_string_literal: true

class Henchmen
  include Tables

  attr_reader :market_class, :henchmen, :henchmen_by_day

  def initialize(market_class:)
    @market_class = market_class
    @henchmen = []
    @henchmen_by_day = Hash.new { |hash, key| hash[key] = [] }
    roll_henchmen!
    calculate_henchmen_by_day!
  end

  def to_s
    henchmen_by_day.keys.sort.flat_map do |day|
      ["Day #{day}", henchmen_by_day[day].map(&:to_s)]
    end.join("\n")
  end

  HENCHMEN_DICE_BY_MARKET_CLASS_AND_LEVEL = {
    1 => { 0 => "4d100", 1 => "5d20", 2 => "3d10", 3 => "1d10", 4 => "1d6" },
    2 => { 0 => "5d20", 1 => "2d6", 2 => "2d4", 3 => "1d3", 4 => "1d2" },
    3 => { 0 => "4d8", 1 => "1d4", 2 => "1d3", 3 => "85%", 4 => "45%" },
    4 => { 0 => "3d4", 1 => "1d2", 2 => 1, 3 => "33%", 4 => "15%" },
    5 => { 0 => "1d6", 1 => "65%", 2 => "40%", 3 => "15%", 4 => "5%" },
    6 => { 0 => "1d2", 1 => "20%", 2 => "15%", 3 => "5%", 4 => 0 },
  }.freeze
  def roll_henchmen!
    henchmen_by_level = {}
    5.times do |level|
      henchmen_by_level[level] = roll_dice(HENCHMEN_DICE_BY_MARKET_CLASS_AND_LEVEL[@market_class][level])
    end
    henchmen_by_level.each do |level, count|
      next if count.zero?

      count.times do
        @henchmen << Character.new(level,
                                   ethnicity: roll_table(Ship::ShipTables::RANDOM_FLAG_SYRNASOS).downcase,
                                   magic_items: false)
      end
    end
  end

  def calculate_henchmen_by_day!
    henchmen.each do |henchman|
      day = if rand(2).odd?
              rand(1..7)
            else
              rand(8..21)
            end
      @henchmen_by_day[day] << henchman
    end
  end
end
