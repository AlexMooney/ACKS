# frozen_string_literal: true

class Ship
  class LargeShip < Ship
    FLEET_SIZE = "1d6"
    CAPTAIN = 4
    ARTILLERY_CAPACITY = 4
    ARTILLERY_WEIGHT = 800
    LABEL = "large"
    STAT_LINE = "Speed: sail 180' / 72 miles, Cargo 30000 st, AC 2, 200 SHP"

    def initialize(flag:)
      self.crew_size = 20
      generate_passengers!("2d8", 10, ethnicity: flag.downcase)
      generate_cargo!("6d6")
      super
    end
  end
end
