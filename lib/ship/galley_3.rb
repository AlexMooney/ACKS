# frozen_string_literal: true

class Ship
  class Galley3 < Galley
    LABEL = "3-Rower Galley"
    STAT_LINE = "Speed: sail 240' / 96 miles, Oar Sprint 330', Cruise 270', Slow 150' / 54 miles, Cargo 500 st, AC 2, 55 SHP"
    CAPTAIN = 6
    ARTILLERY_CAPACITY = 2
    ARTILLERY_TABLE = ["Heavy Ballista", "Heavy Harpoon Ballista", "Medium Catapult"].freeze
    TREASURE_TYPE = "J"

    def initialize(flag:)
      self.crew_size = 15
      self.rowers = 170
      generate_passengers!("15", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
