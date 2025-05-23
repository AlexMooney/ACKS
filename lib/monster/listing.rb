# frozen_string_literal: true

module Monster
  class Listing
    # This represents the monster encounter data from the Monsterous Manual, as opposed to a specific encounter.
    include Tables

    class << self
      def wilderness_encounter(in_lair: nil)
        in_lair = roll_in_lair(in_lair)

        base_gang = in_lair ? wilderness_lair : wilderness
        Encounter.new(self, base_gang)
      end

      def dungeon_encounter(in_lair: nil)
        in_lair = roll_in_lair(in_lair)

        base_gang = in_lair ? dungeon_lair : dungeon
        Encounter.new(self, base_gang)
      end

      private

      def roll_in_lair(in_lair)
        if in_lair.nil?
          roll_dice(lair_chance).positive?
        else
          in_lair
        end
      end
    end
  end
end
