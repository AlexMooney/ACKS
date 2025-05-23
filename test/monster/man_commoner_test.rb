# frozen_string_literal: true

require "test_helper"

describe Monster::Listing::ManCommoner do
  def subject
    Monster::Listing::ManCommoner
  end

  it "rolls a dungeon encounter" do
    encounter = subject.dungeon_encounter(in_lair: false)
    assert encounter.is_a?(Monster::Encounter)
    assert_equal Monster::Listing::ManCommoner, encounter.listing
    assert_equal 0, encounter.leaders.length # TODO: add leader
    assert_equal [], encounter.treasures

    assert encounter.characters_by_count.is_a?(Hash)
    assert encounter.characters_by_count["commoner"].positive?
    assert_equal 0, encounter.characters_by_count["noncombatant"]
    assert_equal 0, encounter.characters_by_count["juvenile"]
    assert_equal 0, encounter.characters_by_count["ox"]
    assert_equal 0, encounter.characters_by_count["pig"]
    assert_equal 0, encounter.characters_by_count["cow"]
    assert_equal 0, encounter.characters_by_count["sheep"]
  end

  it "rolls a dungeon lair encounter" do
    encounter = subject.dungeon_encounter(in_lair: true)
    assert encounter.is_a?(Monster::Encounter)
    assert_equal Monster::Listing::ManCommoner, encounter.listing
    assert_equal 0, encounter.leaders.length # TODO: add leader
    assert_equal ["A"], encounter.treasures

    assert encounter.characters_by_count.is_a?(Hash)
    assert encounter.characters_by_count["commoner"].positive?
    commoners = encounter.characters_by_count["commoner"]
    assert_equal commoners, encounter.characters_by_count["noncombatant"]
    assert_equal 3 * commoners, encounter.characters_by_count["juvenile"]
    assert_equal 0, encounter.characters_by_count["ox"]
    assert_equal 0, encounter.characters_by_count["pig"]
    assert_equal 0, encounter.characters_by_count["cow"]
    assert_equal 0, encounter.characters_by_count["sheep"]
  end

  it "rolls a wilderness encounter" do
    encounter = subject.wilderness_encounter(in_lair: false)
    assert encounter.is_a?(Monster::Encounter)
    assert_equal Monster::Listing::ManCommoner, encounter.listing
    assert_equal 0, encounter.leaders.length # TODO: add leader
    assert_equal ["A"], encounter.treasures

    assert encounter.characters_by_count.is_a?(Hash)
    assert encounter.characters_by_count["commoner"].positive?
    assert_equal 0, encounter.characters_by_count["noncombatant"]
    assert_equal 0, encounter.characters_by_count["juvenile"]
    assert_equal 0, encounter.characters_by_count["ox"]
    assert_equal 0, encounter.characters_by_count["pig"]
    assert_equal 0, encounter.characters_by_count["cow"]
    assert_equal 0, encounter.characters_by_count["sheep"]
  end

  it "rolls a wilderness lair encounter" do
    encounter = subject.wilderness_encounter(in_lair: true)
    assert encounter.is_a?(Monster::Encounter)
    assert_equal Monster::Listing::ManCommoner, encounter.listing
    assert_equal 0, encounter.leaders.length # TODO: add leader
    assert [1, 2, 3].include?(encounter.treasures.length)
    assert(encounter.treasures.all? { |treasure| treasure == "A" })

    assert encounter.characters_by_count.is_a?(Hash)
    assert encounter.characters_by_count["commoner"].positive?
    commoners = encounter.characters_by_count["commoner"]
    assert_equal commoners, encounter.characters_by_count["noncombatant"]
    assert_equal 3 * commoners, encounter.characters_by_count["juvenile"]
    assert_equal commoners, encounter.characters_by_count["ox"]
    assert_equal commoners, encounter.characters_by_count["pig"]
    assert_equal 3 * commoners, encounter.characters_by_count["cow"]
    assert_equal 32 * commoners, encounter.characters_by_count["sheep"]
  end
end
