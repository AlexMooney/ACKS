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

  test "generates build for human character" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    valid_builds = CharacterLegacy::Descriptions::Human::HUMAN_BUILD.values.uniq
    assert_includes valid_builds, character.build
  end

  test "generates height in reasonable range" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    assert_includes 45..90, character.height_inches
  end

  test "generates weight in reasonable range" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    assert_includes 40..450, character.weight_lbs
  end

  test "non-human ethnicity skips physical description" do
    character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
    assert_nil character.build
    assert_nil character.height_inches
    assert_nil character.weight_lbs
  end

  test "generates appearance for human character" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    assert_not_nil character.eye_color
    assert_not_nil character.skin_color
    assert_not_nil character.hair_color
    assert_not_nil character.hair_texture
  end

  test "non-human ethnicity skips appearance" do
    character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
    assert_nil character.eye_color
    assert_nil character.skin_color
    assert_nil character.hair_color
    assert_nil character.hair_texture
  end

  test "generates features for human character" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    assert_not_nil character.features
    assert_not_empty character.features
  end

  test "features resolves gendered slash notation" do
    # Features like "Face - Handsome/Beautiful" should resolve to one side
    # but belongings can legitimately contain "/" (e.g. "Too Big/Small")
    20.times do
      character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
      character.features.split(", ").each do |feature|
        next unless feature.match?(/\A\w+ - /)

        refute_match %r{/}, feature, "Gendered feature should be resolved: #{feature}"
      end
    end
  end

  test "non-human ethnicity skips features" do
    character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
    assert_nil character.features
  end

  test "overrides name when provided" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { name: "TestName" }).generate
    assert_equal "TestName", character.name
  end

  test "overrides sex when provided" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { sex: "female" }).generate
    assert_equal "female", character.sex
  end

  test "overrides alignment when provided" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { alignment: "Chaotic" }).generate
    assert_equal "Chaotic", character.alignment
  end

  test "overrides ethnicity when provided" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { ethnicity: "kemeshi" }).generate
    assert_equal "kemeshi", character.ethnicity
  end

  test "overrides template when provided" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { template: 10 }).generate
    assert_equal 10, character.template
  end

  test "overrides individual stats when provided" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { str: 18, cha: 3 }).generate
    assert_equal 18, character.str
    assert_equal 3, character.cha
    # Non-overridden stats should still be rolled
    assert_includes 3..18, character.int
  end

  test "overrides physical attributes when provided" do
    character = CharacterGenerator.new(
      character_class: "Fighter", level: 1,
      overrides: { build: "Skinny", height_inches: 72, weight_lbs: 180 },
    ).generate
    assert_equal "Skinny", character.build
    assert_equal 72, character.height_inches
    assert_equal 180, character.weight_lbs
  end

  test "overrides appearance when provided" do
    character = CharacterGenerator.new(
      character_class: "Fighter", level: 1,
      overrides: { eye_color: "red", hair_color: "white" },
    ).generate
    assert_equal "red", character.eye_color
    assert_equal "white", character.hair_color
  end

  test "overrides features when provided" do
    character = CharacterGenerator.new(
      character_class: "Fighter", level: 1,
      overrides: { features: "Tall, Dark, Handsome" },
    ).generate
    assert_equal "Tall, Dark, Handsome", character.features
  end

  test "passes through title override" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { title: "Lord" }).generate
    assert_equal "Lord", character.title
  end

  test "ignores blank override values" do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1, overrides: { name: "", alignment: "" }).generate
    assert_not_nil character.name
    assert_not_empty character.name
    assert_includes %w[Lawful Neutral Chaotic], character.alignment
  end
end
