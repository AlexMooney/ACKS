# frozen_string_literal: true

require "test_helper"

class CharacterGeneratorTest < ActiveSupport::TestCase
  test "generates all six ability scores in valid range" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate

    %i[str int wil dex con cha].each do |stat|
      assert_includes 3..18, character.send(stat), "#{stat} should be 3-18"
    end
  end

  test "primary stat for fighter is at least 13" do
    20.times do
      character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
      assert character.str >= 13, "Fighter STR was #{character.str}, expected >= 13"
    end
  end

  test "primary stat for mage is at least 13" do
    20.times do
      character = CharacterGenerator.new(character_class: "Mage", level: 1).generate
      assert character.int >= 13, "Mage INT was #{character.int}, expected >= 13"
    end
  end

  test "sets character_class and class_type" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 3).generate

    assert_equal "Fighter", character.character_class
    assert_equal "fighter", character.class_type
    assert_equal 3, character.level
  end

  test "randomly picks class when none specified" do
    character = CharacterGenerator.new(level: 1).generate

    assert_not_nil character.character_class
    assert_not_nil character.class_type
  end

  test "returns an unsaved Character record" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate

    assert_instance_of Character, character
    assert character.new_record?
  end

  test "generates sex based on class" do
    # Bladedancer is always female
    character = CharacterGenerator.new(character_class: "Bladedancer", level: 1).generate
    assert_equal "female", character.sex
  end

  test "generates alignment" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    assert_includes %w[Lawful Neutral Chaotic], character.alignment
  end

  test "generates ethnicity from valid set" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    valid = CharacterLegacy::Descriptions::Human::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys
    assert_includes valid, character.ethnicity
  end

  test "dwarven class gets dwarven ethnicity" do
    character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
    assert_equal "dwarven", character.ethnicity
  end

  test "elven class gets elven ethnicity" do
    character = CharacterGenerator.new(character_class: "Elven Spellsword", level: 1).generate
    assert_equal "elven", character.ethnicity
  end

  test "generates template as 3-18" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    assert_includes 3..18, character.template
  end
end
