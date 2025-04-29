# frozen_string_literal: true

require "csv"

class TTMagicItems
  def self.roll_magic_items(common: 0, uncommon: 0, rare: 0)
    items = {}
    items[:common] = generate_items("common", common) if common.positive?
    items[:uncommon] = generate_items("uncommon", uncommon) if uncommon.positive?
    items[:rare] = generate_items("rare", rare) if rare.positive?
    items
  end

  def self.format_items(magic_items_by_rarity)
    magic_item_list = magic_items_by_rarity.filter_map do |rarity, items|
      next if items&.empty?

      "#{rarity.capitalize} magic items: " + items.map(&:to_s).sort.join(", ")
    end
    magic_item_list = nil if magic_item_list&.empty?
    magic_item_list
  end

  def self.generate_items(quality, quantity)
    type_by_frequency = type_by_quality[quality]
    quantity.times.map do
      type = roll_weighted(type_by_frequency)
      item_weights = item_weights_by_rarity_and_type(quality, type)
      roll_weighted(item_weights)
    end
  end

  def self.random_item_type(quality)
    roll_weighted(type_by_quality[quality])
  end

  def self.type_by_quality
    @type_by_quality ||= CSV.parse(File.read(File.expand_path("magic_items/frequencies.csv", __dir__)),
                                   headers: true).each_with_object({}) do |line, result|
      result[line["rarity"]] = line.to_h.except("rarity").transform_values(&:to_i)
    end
  end

  def self.item_weights_by_rarity_and_type(rarity, type)
    @item_weights_by_rarity_and_type ||= Hash.new do |h, k|
      h[k] = Hash.new do |hh, kk|
        hh[kk] = CSV.parse(File.read(File.expand_path("magic_items/#{k}_#{kk}.csv", __dir__)),
                           headers: true).each_with_object({}) do |line, result|
          result[line["Name"]] = line["Share"].to_i
        end
      end
    end
    @item_weights_by_rarity_and_type[rarity][type]
  end

  def self.roll_weighted(value_by_weight)
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
