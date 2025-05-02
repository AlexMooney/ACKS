# frozen_string_literal: true

require "test_helper"

describe TTMagicItems do
  describe ".roll_magic_items" do
    it "returns a hash of magic items by rarity" do
      result = TTMagicItems.new(common: 1, uncommon: 1, rare: 1).magic_items_by_rarity
      assert_instance_of Hash, result
      assert_includes result.keys, :common
      assert_includes result.keys, :uncommon
      assert_includes result.keys, :rare
    end

    it "returns an empty hash if all quantities are zero" do
      result = TTMagicItems.new(common: 0, uncommon: 0, rare: 0).magic_items_by_rarity
      assert_instance_of Hash, result
      assert_empty result
    end
  end

  describe ".items_to_s" do
    it "converts the magic item hash to a formatted string" do
      magic_items_by_rarity = { common: %w[Item1 Item2], uncommon: ["Item3"], rare: [] }
      magic_items = TTMagicItems.new
      magic_items.instance_variable_set(:@magic_items_by_rarity, magic_items_by_rarity)
      expected_result = "Common magic items: Item1, Item2\nUncommon magic items: Item3"
      assert_equal expected_result, magic_items.to_s
    end
  end
end
