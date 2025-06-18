# frozen_string_literal: true

require "test_helper"

describe Character do
  it "returns a hash of magic items by rarity" do
    result = Character.new(1)
    assert_equal 1, result.level
    assert_instance_of Hash, result.magic_items_by_rarity
    assert_instance_of Character::Stats, result.stats
  end

  it "handles every ethnicity" do
    not_implemented_names = %w[krysean kushtu shebatean skysos]
    Character::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.each_key do |ethnicity|
      character = Character.new(1, ethnicity:)
      assert_match(/#{ethnicity}/i, character.description)
      refute_match(/\ANot Implemented/, character.name) unless not_implemented_names.include?(ethnicity)
    end
  end
end
