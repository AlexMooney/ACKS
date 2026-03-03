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
end
