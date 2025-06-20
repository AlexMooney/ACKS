# frozen_string_literal: true

class Ship
  class SmallShip < Ship
    FLEET_SIZE = "1d12"
    CAPTAIN = 1
    ARTILLERY_CAPACITY = 1
    ARTILLERY_WEIGHT = 400
    LABEL = "small"
    STAT_LINE = "Speed: sail 240' / 96 miles, Cargo 10000 st, AC 2, 75 SHP"

    def initialize(flag:)
      self.crew_size = 10 # 20 40
      generate_passengers!("6d10", ethnicity: flag.downcase) # 2d8*10 4d6*10
      generate_cargo!("3d4") # 6d6 7d10
      super
    end
  end
end
