# frozen_string_literal: true

class Ship
  class Galley1 < Galley
    LABEL = "1-Rower Galley"
    STAT_LINE = "Speed: sail 240' / 96 miles, Oar Sprint 240', Cruise 150', Slow 90' / 30 miles, Cargo 500 st, AC 2, 15 SHP"
    CAPTAIN = 3
    ARTILLERY_CAPACITY = 1
    ARTILLERY_TABLE = ["Medium Ballista", "Light Catapult"].freeze
    TREASURE_TYPE = "E/2"

    def initialize(flag:, skip_captain: false)
      self.crew_size = 3
      self.rowers = 30
      # generate_passengers!("0", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
