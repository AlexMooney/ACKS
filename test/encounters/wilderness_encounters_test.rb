# frozen_string_literal: true

require "test_helper"

describe Encounters::WildernessEncounters do
  it "returns a description of the encounter" do
    encounters = Encounters::WildernessEncounters.new("2") # Danger level
    list = encounters.wilderness_encounters("scrubland_sparse")
  end
end
