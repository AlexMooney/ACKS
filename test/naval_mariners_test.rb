# frozen_string_literal: true

require "test_helper"

describe "Naval Mariners" do
  it "generates a single ship without blowing up" do
    encounter = NavalMariners.new(lair: false)
    assert_nil encounter.commodore
    assert_equal 1, encounter.ships.size
    assert_kind_of Ship::Galley, encounter.ships.first
    assert_instance_of Character, encounter.ships.first.captain
  end

  it "generates a fleet without blowing up" do
    encounter = NavalMariners.new(lair: true)
    assert_instance_of Character, encounter.commodore
    highest_captain_level = encounter.ships.map(&:captain).map(&:level).max
    assert_equal encounter.commodore.level, highest_captain_level + 1
  end
end
