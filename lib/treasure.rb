# frozen_string_literal: true

require "csv"

class Treasure
  include Tables

  attr_reader :quantity_by_type

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
    @quantity_by_type = Hash.new(0)
    %w[cp sp ep gp pp].each do |coin_type|
      quantity_by_type[coin_type] = 0 # Make sure coins print before special treasure
    end
    treasure_types.each_char do |type|
      roll_for_type(type.upcase)
    end
    quantity_by_type.delete_if { |_, quantity| quantity.zero? }
  end

  def to_s
    return "No treasure." if @quantity_by_type.empty?

    treasure_string = @quantity_by_type.map do |type, quantity|
      "#{quantity} #{type}"
    end.join("\n")
    ["Treasure:", treasure_string].join("\n")
  end

  private

  def roll_for_type(type)
    return nil unless self.class.treasure_table[type]

    treasure_data = self.class.treasure_table[type]

    %w[cp sp ep gp pp].each do |component|
      chance = treasure_data[:"#{component}_chance"]
      next if roll_dice("#{chance}%").zero?

      dice_string = treasure_data[:"#{component}_amount"]
      amount_rolled = roll_dice(dice_string)
      amount_rolled.times do
        lot = Lot.new(component)
        quantity_by_type[lot.type] += lot.amount
      end
    end

    gems_chance = treasure_data[:gem_chance]
    if roll_dice("#{gems_chance}%").positive?
      amount_rolled = roll_dice(treasure_data[:gem_amount])
      amount_rolled.times do
        lot = Lot.new(treasure_data[:gem_type])
        quantity_by_type[lot.type] += lot.amount
      end
    end

    jewelry_chance = treasure_data[:jewelry_chance]
    if roll_dice("#{jewelry_chance}%").positive? # rubocop:disable Style/GuardClause
      amount_rolled = roll_dice(treasure_data[:jewelry_amount])
      amount_rolled.times do
        lot = Lot.new(treasure_data[:jewelry_type])
        quantity_by_type[lot.type] += lot.amount
      end
    end
  end
end
