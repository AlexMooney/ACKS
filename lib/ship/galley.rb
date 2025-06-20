# frozen_string_literal: true

class Ship
  class Galley < Ship
    attr_accessor :rowers, :treasure

    def initialize(flag:)
      super
      generate_treasure!
    end

    def <=>(other)
      return nil unless other.is_a?(Galley)

      [other.class::CAPTAIN, other.class::LABEL] <=> [self.class::CAPTAIN, self.class::LABEL]
    end

    def generate_treasure!
      self.treasure = Treasure.new(self.class::TREASURE_TYPE, only_coins: true)
    end

    def assign_artillery!
      @artillery_pieces = []

      artillery_capacity.times do
        @artillery_pieces << roll_table(self.class::ARTILLERY_TABLE)
      end
    end

    def artillery_string
      @artillery_pieces.empty? ? "No artillery" : @artillery_pieces.sort.join(", ")
    end

    def to_s
      [
        stat_line,
        "#{crew_size}× crew, #{rowers}× rowers, #{artillery_string}",
        captain,
        passengers,
        treasure.to_s,
        "",
      ].join("\n")
    end
  end
end
