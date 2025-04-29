# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/tt_magic_items"

describe TTMagicItems do
  describe ".roll_magic_items" do
    it "returns a hash of magic items by rarity" do
      result = TTMagicItems.roll_magic_items(common: 1, uncommon: 1, rare: 1)
      assert_instance_of Hash, result
      assert_includes result.keys, :common
      assert_includes result.keys, :uncommon
      assert_includes result.keys, :rare
    end

    it "returns an empty hash if all quantities are zero" do
      result = TTMagicItems.roll_magic_items(common: 0, uncommon: 0, rare: 0)
      assert_instance_of Hash, result
      assert_empty result
    end
  end

  describe ".items_to_s" do
    it "converts the magic item hash to a formatted string" do
      magic_items = {
        common: ["Item1", "Item2"],
        uncommon: ["Item3"],
        rare: []
      }
      result = TTMagicItems.items_to_s(magic_items)
      expected_result = "Common magic items: Item1, Item2\nUncommon magic items: Item3"
      assert_equal expected_result, result
    end
  end
end
