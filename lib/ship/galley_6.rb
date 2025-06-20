# frozen_string_literal: true

class Ship
  class Galley6 < Galley
    LABEL = "6-Rower Galley"
    STAT_LINE = "Speed: sail 150' / 60 miles, Oar Sprint 270', Cruise 210', Slow 120' / 42 miles, Cargo 6000 st, AC 2, 140 SHP"
    CAPTAIN = 6
    ARTILLERY_CAPACITY = 4
    ARTILLERY_TABLE = ["Heavy Ballista", "Heavy Harpoon Ballista", "Medium Catapult", "Light Trebuchet"].freeze
    TREASURE_TYPE = "O"

    def initialize(flag:)
      self.crew_size = 20
      self.rowers = 336
      generate_passengers!("100", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
