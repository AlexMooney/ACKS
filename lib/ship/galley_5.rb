# frozen_string_literal: true

class Ship
  class Galley5 < Galley
    LABEL = "5-Rower Galley"
    STAT_LINE = "Speed: sail 150' / 66 miles, Oar Sprint 270', Cruise 240', Slow 120' / 48 miles, Cargo 5750 st, AC 2, 120 SHP"
    CAPTAIN = 6
    ARTILLERY_CAPACITY = 3
    ARTILLERY_TABLE = ["Heavy Ballista", "Heavy Harpoon Ballista", "Medium Catapult"].freeze
    TREASURE_TYPE = "L"

    def initialize(flag:, skip_captain: false)
      self.crew_size = 20
      self.rowers = 300
      generate_passengers!("75", ethnicity: flag.downcase, passenger_type: Marines)
      super
    end
  end
end
