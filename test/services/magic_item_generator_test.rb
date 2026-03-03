# frozen_string_literal: true

require "test_helper"

class MagicItemGeneratorTest < ActiveSupport::TestCase
  test "returns an array of MagicItemInstance records" do
    instances = MagicItemGenerator.new(common: 1).generate
    assert_kind_of Array, instances
    assert_instance_of MagicItemInstance, instances.first
  end

  test "returns unsaved records" do
    instances = MagicItemGenerator.new(common: 1).generate
    assert instances.all?(&:new_record?)
  end

  test "generates requested number of items per rarity" do
    instances = MagicItemGenerator.new(common: 3, uncommon: 2).generate
    common_count = instances.count { |i| i.magic_item.rarity == "common" }
    uncommon_count = instances.count { |i| i.magic_item.rarity == "uncommon" }
    assert_equal 3, common_count
    assert_equal 2, uncommon_count
  end

  test "each instance has a magic_item reference" do
    instances = MagicItemGenerator.new(common: 5).generate
    instances.each do |instance|
      assert_not_nil instance.magic_item
      assert_instance_of MagicItem, instance.magic_item
    end
  end

  test "resolves Scroll of Creature Warding into specific creature" do
    warding = magic_items(:creature_warding)
    instance = MagicItemInstance.new(magic_item: warding)
    resolved = MagicItemGenerator.new.send(:resolve_name, warding.name)

    assert_not_nil resolved
    assert_match(/\AScroll of Warding vs\. /, resolved)
  end

  test "resolves Spell Scroll template into specific spells" do
    scroll = magic_items(:spell_scroll_1)
    resolved = MagicItemGenerator.new.send(:resolve_name, scroll.name)

    assert_not_nil resolved
    assert_match(/(Arcane|Divine) Scroll in .+ with /, resolved)
  end

  test "resolves versus X weapon into specific creature" do
    sword = magic_items(:versus_x_sword)
    resolved = MagicItemGenerator.new.send(:resolve_name, sword.name)

    assert_not_nil resolved
    refute_includes resolved, "versus X"
    assert_match(/versus /, resolved)
  end

  test "non-template items have nil override_name" do
    instances = MagicItemGenerator.new(common: 20).generate
    non_template = instances.find { |i| !i.magic_item.name.match?(/Spell Scroll|Creature Warding|versus X/) }
    if non_template
      assert_nil non_template.override_name
    end
  end

  test "returns empty array when all quantities are zero" do
    instances = MagicItemGenerator.new(common: 0).generate
    assert_empty instances
  end
end
