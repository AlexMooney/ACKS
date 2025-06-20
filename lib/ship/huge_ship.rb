# frozen_string_literal: true

class Ship
  class HugeShip < Ship
    FLEET_SIZE = "1d3"
    CAPTAIN = 5
    ARTILLERY_CAPACITY = 8
    ARTILLERY_WEIGHT = 800
    LABEL = "huge"
    STAT_LINE = "Speed: sail 180' / 60 miles, Cargo 50000 st, AC 2, 400 SHP"

    def initialize(flag:)
      self.crew_size = 40
      generate_passengers!("4d6", 10, ethnicity: flag.downcase)
      generate_cargo!("7d10")
      super
    end
  end
end
