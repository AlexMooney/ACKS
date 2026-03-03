# frozen_string_literal: true

require "test_helper"

class MagicItemTest < ActiveSupport::TestCase
  VALID_RARITIES = %w[common uncommon rare very_rare legendary].freeze
  VALID_ITEM_TYPES = %w[potions rings scrolls implements misc swords weapons armor].freeze

  setup do
    Rails.application.load_seed if MagicItem.count.zero?
  end

  test "seeds populate magic items" do
    assert MagicItem.count > 1000, "Expected at least 1000 magic items, got #{MagicItem.count}"
  end

  test "all rarities present" do
    rarities = MagicItem.distinct.pluck(:rarity).sort
    assert_equal VALID_RARITIES.sort, rarities
  end

  test "all item types present" do
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

  test "potions have descriptions" do
    potions_without_desc = MagicItem.where(item_type: "potions", description: [nil, ""])
    assert_equal 0, potions_without_desc.count,
                 "Potions without descriptions: #{potions_without_desc.pluck(:name)}"
  end

  test "seeds are idempotent" do
    count_before = MagicItem.count
    Rails.application.load_seed
    assert_equal count_before, MagicItem.count
  end
end
