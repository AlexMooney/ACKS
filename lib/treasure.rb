# frozen_string_literal: true

require "csv"

class Treasure
  include Tables

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
          average_value: row["AVG_VALUE"].to_i,
          magic_items: row["MAGIC_ITEMS"],
          average_magic_items: row["AVG_MAGIC_VALUE"].to_i,
        }
      end
      table
    end
  end

  attr_reader :treasure_types, :only_coins, :divisor, :treasure_lots, :magic_items

  def initialize(treasure_types, only_coins: false)
    @treasure_types, @divisor = treasure_types.split("/", 2)
    @divisor ||= 1
    @divisor = @divisor.to_i
    @only_coins = only_coins
    @treasure_lots = []
    @treasure_types.each_char(&method(:roll_for_type))
    treasure_lots.delete_if { |lot| lot.amount.zero? }

    @magic_items_by_rarity = { common: 0, uncommon: 0, rare: 0, very_rare: 0, legendary: 0 }
    @treasure_types.each_char { |type| roll_for_magic_items!(type) }
    @magic_items = TTMagicItems.new(**@magic_items_by_rarity)
  end

  def to_s
    average_value = @treasure_types.chars.sum { |type| self.class.treasure_table[type][:average_value] } / divisor
    return "Average treasure: #{average_value}gp\nNo treasure." if @treasure_lots.empty?

    treasures_by_group = @treasure_lots.group_by(&:group_attributes)
    treasure_totals = treasures_by_group.values.map { |lots| lots.sum(lots.first.zero) }
    running_weight_total = running_value_total = 0
    treasure_table_data = treasure_totals.sort.map do |lot|
      running_value_total += lot.gold_value * lot.amount
      running_weight_total += lot.weight * lot.amount
      [lot.to_s, "#{running_value_total.round}gp", "#{(running_weight_total / 1000.0).round(1)} st"]
    end
    table = TTY::Table.new(["Treasure", "Value Subtotal", "Weight Subtotal"], treasure_table_data, width: 100)

    ["Average treasure: #{average_value}gp",
     "Treasure worth #{running_value_total}gp (#{(100 * running_value_total / average_value).round}%)",
     "",
     table.render_with(MarkdownBorder),
     "",
     "Magic items by rarity: #{@magic_items_by_rarity}",
     magic_items.to_s].join("\n")
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
        lot = roll_for_lot(component)
        lot = roll_for_lot(component) while only_coins && lot.weight > 1
        treasure_lots << (lot / divisor)
      end
    end

    gems_chance = treasure_data[:gem_chance]
    if roll_dice("#{gems_chance}%").positive?
      amount_rolled = roll_dice(treasure_data[:gem_amount])
      amount_rolled.times do
        lot = roll_for_lot(treasure_data[:gem_type])
        lot = roll_for_lot(treasure_data[:gem_type]) while only_coins && lot.weight > 1
        treasure_lots << (lot / divisor)
      end
    end

    jewelry_chance = treasure_data[:jewelry_chance]
    if roll_dice("#{jewelry_chance}%").positive? # rubocop:disable Style/GuardClause
      amount_rolled = roll_dice(treasure_data[:jewelry_amount])
      amount_rolled.times do
        treasure_lots << (roll_for_lot(treasure_data[:jewelry_type]) / divisor)
      end
    end
  end

  def roll_for_magic_items!(type)
    # "100% 5d6 common, 100% 4d6 uncommon, 90% 3d6 rare, 80% 2d4 very_rare, 60% 1d3 legendary"
    magic_item_string = self.class.treasure_table.dig(type, :magic_items)
    return unless magic_item_string

    magic_item_string.split(",").map(&:strip).each do |sub_string|
      chance, dice_string, rarity = sub_string.split(" ", 3)
      next if roll_dice(chance).zero?

      quantity = roll_dice(dice_string)
      remainder = quantity % divisor
      extra = rand(divisor) < remainder ? 1 : 0
      quantity = (quantity / divisor).to_i + extra

      @magic_items_by_rarity[rarity.to_sym] += quantity
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
      roll_table(SpecialTreasureTables::ORNAMENTAL_GOODS_TABLE)
    when "gems"
      roll_table(SpecialTreasureTables::GEM_GOODS_TABLE)
    when "brilliants"
      roll_table(SpecialTreasureTables::BRILLIANT_GOODS_TABLE)
    when "trinkets"
      roll_table(SpecialTreasureTables::TRINKET_GOODS_TABLE)
    when "jewelry"
      roll_table(SpecialTreasureTables::JEWELRY_GOODS_TABLE)
    when "regalia"
      roll_table(SpecialTreasureTables::REGALIA_GOODS_TABLE)
    else
      raise "Unknown lot type: #{type.inspect}"
    end.roll
  end
end
