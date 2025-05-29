# frozen_string_literal: true

module Monster
  class Encounter
    # This represents an instance of a monster encounter.

    attr_reader :listing, :in_lair, :characters_by_count, :leaders, :treasures

    def initialize(listing, gang, in_lair:)
      @listing = listing
      @in_lair = in_lair
      @characters_by_count = Hash.new(0)
      @leaders = []
      @treasures = []
      gang.roll(self)
    end

    def to_s
      creature_list = @characters_by_count.map do |type, count|
        "#{count}× #{type}"
      end.join(", ")
      leader_list = @leaders.map(&:to_s).tally.map do |leader_string, count|
        if count == 1
          leader_string
        else
          "#{count}× #{leader_string}"
        end
      end

      ["#{listing.name}#{in_lair ? ' Lair' : nil}", creature_list].concat(leader_list).join("\n")
    end
  end
end
