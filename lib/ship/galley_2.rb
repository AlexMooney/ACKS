# frozen_string_literal: true

class Ship
  class Galley2 < Galley
    LABEL = "2-Rower Galley"
    STAT_LINE = "Speed: sail 240' / 96 miles, Oar Sprint 270', Cruise 180', Slow 90' / 36 miles, Cargo 1000 st, AC 2, 25 SHP"
    CAPTAIN = 4
    ARTILLERY_CAPACITY = 2
    ARTILLERY_TABLE = ["Medium Ballista", "Medium Catapult"].freeze
    TREASURE_TYPE = "G"

    def initialize(flag:)
      self.crew_size = 5
      self.rowers = 90
      generate_passengers!("10", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
