# frozen_string_literal: true

class Ship
  class Galley15 < Galley
    LABEL = "1.5-Rower Galley"
    STAT_LINE = "Speed: sail 300' / 96 miles, Oar Sprint 270', Cruise 180', Slow 90' / 30 miles, Cargo 750 st, AC 2, 20 SHP"
    CAPTAIN = 5
    # It can carry 2 war machines weighing up to 150 st each.
    ARTILLERY_CAPACITY = 2
    ARTILLERY_TABLE = ((["Medium Ballista"] * 5) + ["Fire-Bearing Siphon", "Light Catapult"]).freeze
    TREASURE_TYPE = "J"

    def initialize(flag:, skip_captain: false)
      self.crew_size = 5
      self.rowers = 50
      generate_passengers!("5", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
