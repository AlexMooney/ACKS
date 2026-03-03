# frozen_string_literal: true

require "test_helper"

class MagicItemTest < ActiveSupport::TestCase
  VALID_RARITIES = %w[common uncommon rare very_rare legendary].freeze
  VALID_ITEM_TYPES = %w[potions rings scrolls implements misc swords weapons armor].freeze

  test "fixtures include all rarities" do
    rarities = MagicItem.distinct.pluck(:rarity).sort
    assert_equal VALID_RARITIES.sort, rarities
  end

  test "fixtures include all item types" do
    item_types = MagicItem.distinct.pluck(:item_type).sort
    assert_equal VALID_ITEM_TYPES.sort, item_types
  end

  test "no duplicate name+rarity+item_type" do
    dupes = MagicItem.group(:name, :rarity, :item_type).having("COUNT(*) > 1").count
    assert_empty dupes, "Found duplicate items: #{dupes.keys.inspect}"
  end

  test "every item has a name and share" do
    nameless = MagicItem.where(name: [nil, ""])
    assert_equal 0, nameless.count, "Items without names: #{nameless.pluck(:id)}"

    shareless = MagicItem.where(share: [nil, 0])
    assert_equal 0, shareless.count, "Items without share: #{shareless.pluck(:id, :name)}"
  end

  test "validates required fields" do
    item = MagicItem.new
    refute item.valid?
    assert_includes item.errors[:name], "can't be blank"
    assert_includes item.errors[:rarity], "can't be blank"
    assert_includes item.errors[:item_type], "can't be blank"
  end
end
