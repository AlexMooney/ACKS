# frozen_string_literal: true

class Ship
  class Galley4 < Galley
    LABEL = "4-Rower Galley"
    STAT_LINE = "Speed: sail 180' / 72 miles, Oar Sprint 300', Cruise 240', Slow 120' / 48 miles, Cargo 2000 st, AC 2, 65 SHP"
    CAPTAIN = 6
    ARTILLERY_CAPACITY = 2
    ARTILLERY_TABLE = ["Heavy Ballista", "Heavy Harpoon Ballista", "Medium Catapult"].freeze
    TREASURE_TYPE = "L"

    def initialize(flag:, skip_captain: false)
      self.crew_size = 15
      self.rowers = 180
      generate_passengers!("75", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
