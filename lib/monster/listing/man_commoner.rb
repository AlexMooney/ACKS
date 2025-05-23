# frozen_string_literal: true

module Monster
  class Listing
    class ManCommoner < Listing
      class << self
        def name
          "Man, Commoner"
        end

        def lair_chance
          "40%"
        end

        # TODO: add leaders
        # TODO: all commoner leaders are middle aged, with penalties compared to base Fighters.
        def wilderness
          Gang.new(group_name: "Band",
                   count_dice: "1d6",
                   leader_class: nil, # Monster::Leader::Fighter(level: 2, title: "reeve"),
                   treasure: "A",
                   subordinate_gang: work_gang)
        end

        def wilderness_lair
          Gang.new(group_name: "Hamlet",
                   count_dice: "1d3",
                   subordinate_gang: wilderness,
                   leader_class: nil, # Monster::Leader::Fighter(level: 3, title: "steward"),
                   extra_creature_block: method(:hamlet_extras))
        end

        def dungeon
          work_gang
        end

        def dungeon_lair
          Gang.new(group_name: "Homestead",
                   count_dice: "1",
                   subordinate_gang: wilderness,
                   extra_creature_block: method(:homestead_extras))
        end

        private

        def work_gang
          @work_gang ||= Gang.new(group_name: "Work-gang",
                                  creature: "commoner",
                                  count_dice: "2d6",
                                  leader_class: nil) # Monster::Leader::Fighter(level: 1, title: "yeoman"))
        end

        def hamlet_extras(encounter)
          base_count = encounter.characters_by_count["commoner"]

          homestead_extras(encounter)
          encounter.characters_by_count["ox"] += base_count
          encounter.characters_by_count["pig"] += base_count
          encounter.characters_by_count["cow"] += 3 * base_count
          encounter.characters_by_count["sheep"] += 32 * base_count

          # priest_class = roll_table(Monster::Leader::RANDOM_DIVINE_CLASS_TABLE)
          # priest_class = Monster::Leader::Crusader if priest_class.name.start_with?("Dwarven")
          # encounter.leaders << priest_class.new(level: 1).new
        end

        def homestead_extras(encounter)
          base_count = encounter.characters_by_count["commoner"]

          encounter.characters_by_count["noncombatant"] += base_count
          encounter.characters_by_count["juvenile"] += 3 * base_count
        end
      end
    end
  end
end
