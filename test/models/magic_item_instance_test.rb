# frozen_string_literal: true

require "test_helper"

class MagicItemInstanceTest < ActiveSupport::TestCase
  test "belongs to a magic item" do
    instance = MagicItemInstance.new(
      magic_item: magic_items(:creature_warding),
      override_name: "Scroll of Warding vs. Dragons"
    )
    assert_equal magic_items(:creature_warding), instance.magic_item
  end

  test "display_name returns override_name when present" do
    instance = MagicItemInstance.new(
      magic_item: magic_items(:creature_warding),
      override_name: "Scroll of Warding vs. Dragons"
    )
    assert_equal "Scroll of Warding vs. Dragons", instance.display_name
  end

  test "display_name falls back to magic_item.name when override is nil" do
    instance = MagicItemInstance.new(magic_item: magic_items(:common_potion))
    assert_equal "Healing Salve", instance.display_name
  end

  test "display_description returns override_description when present" do
    instance = MagicItemInstance.new(
      magic_item: magic_items(:creature_warding),
      override_description: "Wards against dragons in a 30' radius"
    )
    assert_equal "Wards against dragons in a 30' radius", instance.display_description
  end

  test "display_description falls back to magic_item.description when override is nil" do
    instance = MagicItemInstance.new(magic_item: magic_items(:common_potion))
    assert_equal "smell of camphor and wormwood", instance.display_description
  end

  test "owner is optional" do
    instance = MagicItemInstance.new(magic_item: magic_items(:common_potion))
    assert instance.valid?
  end

  test "magic_item is required" do
    instance = MagicItemInstance.new
    refute instance.valid?
  end

  test "can belong to a character" do
    instance = MagicItemInstance.new(
      magic_item: magic_items(:common_potion),
      owner: characters(:one)
    )
    assert instance.valid?
    assert_equal "Character", instance.owner_type
  end
end
