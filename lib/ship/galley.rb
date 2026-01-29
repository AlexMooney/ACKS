# frozen_string_literal: true

class Ship
  class Galley < Ship
    attr_accessor :rowers, :treasure

    def initialize(flag:, skip_captain: false)
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

    FIRING_ARCS = %w[Fore Port Starboard Aft].freeze
    def assign_artillery!
      @artillery_pieces = []

      arcs = FIRING_ARCS.dup
      artillery_capacity.times do
        @artillery_pieces << "#{arcs.shift} #{roll_table(self.class::ARTILLERY_TABLE)}"
        arcs.shuffle # Always choose fore first then randomly
        arcs = FIRING_ARCS.dup if arcs.empty?
      end
    end

    def artillery_string
      @artillery_pieces.empty? ? "No artillery" : @artillery_pieces.join(", ")
    end

    def has_bulwark?
      @has_bulwark = rand < 0.5 if @has_bulwark.nil?
    end

    def has_ram?
      rand < 0.8
    end

    def additional_weapons
      [
        "#{(passengers.total_count / 8.0).ceil}× boarding ramps",
        (has_ram? ? "Naval Ram" : "").to_s,
        "Fire Pot Pole",
      ].reject(&:empty?).join(", ")
    end

    def to_s
      [
        "### #{ship_class}",
        stat_line,
        additional_weapons,
        "#{crew_size}× crew, #{rowers}× rowers, #{artillery_string}",
        captain,
        passengers,
        treasure.to_s,
        "",
      ].join("\n")
    end
  end
end
