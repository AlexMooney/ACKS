# frozen_string_literal: true

class Ship
  class Galley8 < Galley
    LABEL = "8-Rower Galley"
    STAT_LINE = "Speed: sail 150' / 60 miles, Oar Sprint 240', Cruise 210', Slow 120' / 42 miles, Cargo 8000 st, AC 2, 200 SHP"
    CAPTAIN = 7
    ARTILLERY_CAPACITY = 7
    ARTILLERY_TABLE = ["Heavy Ballista", "Heavy Harpoon Ballista", "Heavy Catapult", "Light Trebuchet"].freeze
    TREASURE_TYPE = "O"

    def initialize(flag:)
      self.crew_size = 50
      self.rowers = 440
      generate_passengers!("150", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
