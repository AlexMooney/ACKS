# frozen_string_literal: true

module MagicItems
  CREATURE_BY_ROLL = ["Angels", "Animals", "Beastment", "Constructs",
                      "Demons", "Dragons", "Dwarves, Gnomes, & Halflings", "Elementals",
                      "Elves, Faeries, & Fey", "Giants", "Humans", "Lycanthropes",
                      "Oozes", "Plants", "Regenerating Creatures", "Sea Creatures",
                      "Spellcasters", "Undead", "Vermin", "Roll Twice"].freeze
  class ScrollCreatureWarding
    include Tables

    def roll_details
      creature = roll_table(CREATURE_BY_ROLL)
      while creature.match?(/Roll Twice/)
        creature = creature.sub("Roll Twice", "#{roll_table(CREATURE_BY_ROLL)} & #{roll_table(CREATURE_BY_ROLL)}")
      end
      "Scroll of Warding vs. #{creature}"
    end
  end
end
