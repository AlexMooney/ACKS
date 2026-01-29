# frozen_string_literal: true

class Ship
  class Galley25 < Galley
    LABEL = "2.5-Rower Galley"
    STAT_LINE = "Speed: sail 360' / 96 miles, Oar Sprint 300', Cruise 240', Slow 120' / 48 miles, Cargo 1250 st, AC 2, 45 SHP"
    CAPTAIN = 5
    # It can carry 2 war machines weighing up to 250 st each.
    ARTILLERY_CAPACITY = 2
    ARTILLERY_TABLE = ((["Medium Ballista"] * 5) + ["Fire-Bearing Siphon", "Medium Catapult"]).freeze
    TREASURE_TYPE = "G"

    def initialize(flag:, skip_captain: false)
      self.crew_size = 10
      self.rowers = 120
      generate_passengers!("10", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
