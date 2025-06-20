# frozen_string_literal: true

require "csv"

class TTMagicItems
  class << self
    def type_by_rarity
      @type_by_rarity ||= CSV.parse(File.read(File.expand_path("magic_items/frequencies.csv", __dir__)), headers: true)
                             .each_with_object({}) do |line, result|
                               result[line["rarity"]] = line.to_h.except("rarity").transform_values(&:to_i)
                             end
    end

    def item_weights_by_rarity_and_type(rarity, type)
      @item_weights_by_rarity_and_type ||= Hash.new do |h, k|
        h[k] = Hash.new do |hh, kk|
          hh[kk] = CSV.parse(File.read(File.expand_path("magic_items/#{k}_#{kk}.csv", __dir__)), headers: true)
                      .each_with_object({}) { |line, result| result[line["Name"]] = line["Share"].to_i }
        end
      end
      @item_weights_by_rarity_and_type[rarity][type]
    end
  end

  attr_reader :magic_items_by_rarity

  def initialize(common: 0, uncommon: 0, rare: 0, very_rare: 0, legendary: 0)
    @magic_items_by_rarity = {}
    @magic_items_by_rarity[:common] = generate_items("common", common) if common.positive?
    @magic_items_by_rarity[:uncommon] = generate_items("uncommon", uncommon) if uncommon.positive?
    @magic_items_by_rarity[:rare] = generate_items("rare", rare) if rare.positive?
    @magic_items_by_rarity[:very_rare] = generate_items("very_rare", rare) if very_rare.positive?
    @magic_items_by_rarity[:legendary] = generate_items("legendary", legendary) if legendary.positive?
    @magic_items_by_rarity.each_value do |items|
      items.map! do |item|
        item.gsub(/Spell Scroll \((\d+) levels?\)/) do
          SpellScroll.new(::Regexp.last_match(1).to_i).roll_details
        end
      end
    end
  end

  def to_s
    magic_items_by_rarity.filter_map do |rarity, items|
      next if items&.empty?

      "#{rarity.capitalize} magic items: " + items.map(&:to_s).sort.join(", ")
    end.join("\n")
  end

  private

  def generate_items(rarity, quantity)
    type_by_frequency = self.class.type_by_rarity[rarity]
    quantity.times.map do
      type = roll_weighted(type_by_frequency)
      item_weights = self.class.item_weights_by_rarity_and_type(rarity, type)
      roll_weighted(item_weights)
    end.sort
  end

  def roll_weighted(value_by_weight)
    total_weight = value_by_weight.values.sum
    roll = rand(1..total_weight)
    cumulative_weight = 0
    value_by_weight.each do |value, weight|
      cumulative_weight += weight
      return value if roll <= cumulative_weight
    end
    raise "Unexpected roll weight"
  end
end

puts TTMagicItems.roll_magic_items(common: 5, uncommon: 5, rare: 5) if __FILE__ == $PROGRAM_NAME
