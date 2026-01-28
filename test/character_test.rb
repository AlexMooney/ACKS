# frozen_string_literal: true

require "test_helper"

describe Character do
  it "rolls for character class, magic items, stats, name, alignment, description" do
    result = Character.new(1)
    assert_equal 1, result.level
    assert_instance_of String, result.character_class
    assert_instance_of Hash, result.magic_items_by_rarity
    assert_instance_of Character::Stats, result.stats
    assert_instance_of String, result.name
    assert_instance_of String, result.alignment
    assert_instance_of Array, result.descriptions
  end

  it "handles every ethnicity" do
    not_implemented_names = %w[krysean kushtu shebatean skysos]
    Character::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.each_key do |ethnicity|
      character = Character.new(2, ethnicity:)
      assert_match(/#{ethnicity}/i, character.descriptions.join(" "))
      refute_match(/\ANot Implemented/, character.name) unless not_implemented_names.include?(ethnicity)
    end
  end

  it "gives 0th level characters the Normal Man class" do
    character = Character.new(0)
    assert_match(/Normal Man/, character.to_s)
  end

  it "calculates armor class based on character class" do
    character = Character.new(5, character_class: "Barbarian")
    assert_equal 4, character.base_ac
    assert_equal "Chain Mail", character.best_armor
    assert_equal "Medium Armor", character.max_armor_type
  end

  it "generates combat stats line" do
    character = Character.new(2, character_class: "Fighter")

    assert_match(/\AHP: \d+, /, character.combat_stats_line)
    assert_match(/AC: \d+ \(Plate \+1/, character.combat_stats_line)
    assert_match(/Melee Attack: \d+\+, 1d6\+\d, /, character.combat_stats_line)
    assert_match(/Ranged Attack: \d+\+, 1d6\+\d\z/, character.combat_stats_line)
  end
end
