# frozen_string_literal: true

require "csv"

class Treasure
  include Tables

  attr_reader :treasure_lots

  class << self
    def treasure_table
      @treasure_table ||= load_treasure_table
    end

    def load_treasure_table
      table = {}
      path = File.expand_path("./treasure/treasure_type_table.csv", __dir__)
      CSV.foreach(path, headers: true) do |row|
        type = row["TREASURE_TYPE"]
        table[type] = {
          cp_chance: row["COPPER_PERCENT"].to_i,
          cp_amount: row["COPPER_AMOUNT"],
          sp_chance: row["SILVER_PERCENT"].to_i,
          sp_amount: row["SILVER_AMOUNT"],
          ep_chance: row["ELECTRUM_PERCENT"].to_i,
          ep_amount: row["ELECTRUM_AMOUNT"],
          gp_chance: row["GOLD_PERCENT"].to_i,
          gp_amount: row["GOLD_AMOUNT"],
          pp_chance: row["PLATINUM_PERCENT"].to_i,
          pp_amount: row["PLATINUM_AMOUNT"],
          gem_chance: row["GEM_PERCENT"].to_i,
          gem_amount: row["GEM_AMOUNT"],
          gem_type: row["GEM_TYPE"],
          jewelry_chance: row["JEWELRY_PERCENT"].to_i,
          jewelry_amount: row["JEWELRY_AMOUNT"],
          jewelry_type: row["JEWELRY_TYPE"],
        }
      end
      table
    end
  end

  def initialize(treasure_types)
    @treasure_lots = []
    treasure_types.each_char(&method(:roll_for_type))
  end

  def to_s
    return "No treasure." if @treasure_lots.empty?

    treasures_by_group = @treasure_lots.group_by(&:group_attributes)
    treasure_totals = treasures_by_group.values.map { |lots| lots.sum(lots.first.zero) }
    treasure_string = treasure_totals.sort.map(&:to_s).join("\n")
    ["Treasure:", treasure_string].join("\n")
  end

  private

  def roll_for_type(type)
    treasure_data = self.class.treasure_table[type]
    raise ArgumentError, "Unknown treasure type: #{type}" unless treasure_data

    %w[cp sp ep gp pp].each do |component|
      chance = treasure_data[:"#{component}_chance"]
      next if roll_dice("#{chance}%").zero?

      dice_string = treasure_data[:"#{component}_amount"]
      amount_rolled = roll_dice(dice_string)
      amount_rolled.times do
        treasure_lots << roll_for_lot(component)
      end
    end

    gems_chance = treasure_data[:gem_chance]
    if false && roll_dice("#{gems_chance}%").positive?
      amount_rolled = roll_dice(treasure_data[:gem_amount])
      amount_rolled.times do
        treasure_lots << roll_for_lot(treasure_data[:gem_type])
      end
    end

    jewelry_chance = treasure_data[:jewelry_chance]
    if false && roll_dice("#{jewelry_chance}%").positive? # rubocop:disable Style/GuardClause
      amount_rolled = roll_dice(treasure_data[:jewelry_amount])
      amount_rolled.times do
        treasure_lots << roll_for_lot(treasure_data[:jewelry_type])
      end
    end
  end

  def roll_for_lot(type)
    case type.downcase
    when "cp"
      SpecialTreasureTables::CP_GOODS_TABLE.sample
    when "sp"
      SpecialTreasureTables::SP_GOODS_TABLE.sample
    when "ep"
      SpecialTreasureTables::EP_GOODS_TABLE.sample
    when "gp"
      SpecialTreasureTables::GP_GOODS_TABLE.sample
    when "pp"
      SpecialTreasureTables::PP_GOODS_TABLE.sample
    when "ornamentals"
      [roll_table(SpecialTreasureTables::GEMS_TABLE, roll_dice("2d20")), 1]
    when "gems"
      [roll_table(SpecialTreasureTables::GEMS_TABLE, roll_dice("1d100")), 1]
    when "brilliants"
      [roll_table(SpecialTreasureTables::GEMS_TABLE, roll_dice("1d100 + 80")), 1]
    when "jewelry"
      JEWELRY_TABLE.sample
    else
      puts "Unknown coin type: #{type.inspect}"
    end.roll
  end
end
