# frozen_string_literal: true

require "test_helper"

describe Encounters::NauticalEncounter do
  it "returns a description of the encounter" do
    encounter = Encounters::NauticalEncounter.new("1")
    assert_equal "Civilized", encounter.danger_label
    assert_equal 1, encounter.raw_danger_level
    assert_match(/\A- \[ \] \w/, encounter.to_s)
  end
end
