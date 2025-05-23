# frozen_string_literal: true

module Monster
  class Gang
    # This describes sub-groups and leadership structures for encounters. An array holds to generate monster encounters.
    #
    # Commoners.gangs = [
    #   Gang.new("Hamlet", "1d3", "steward", 3),
    #   Gang.new("Band", "1d6", "reeve", 2),
    #   Gang.new("Work-gang", "2d6", "yeoman", 1),
    # ]
    include Tables

    attr_reader :group_name, :creature, :subordinate_gang, :count_dice, :leader_class, :treasure, :extra_creature_block

    def initialize(group_name: nil, creature: nil, subordinate_gang: nil, count_dice: "1", leader_class: nil,
                   treasure: nil, extra_creature_block: nil)
      @group_name = group_name
      @creature = creature
      @subordinate_gang = subordinate_gang
      @count_dice = count_dice
      @leader_class = leader_class
      @treasure = treasure
      @extra_creature_block = extra_creature_block
    end

    def roll(encounter)
      if subordinate_gang
        gang_count = roll_dice(count_dice)
        gang_count.times { subordinate_gang.roll(encounter) }
      else
        encounter.characters_by_count[creature] += roll_dice(count_dice)
        encounter.leaders << leader_class.new if leader_class
      end
      encounter.treasures << treasure if treasure
      extra_creature_block&.call(encounter)

      encounter
    end

    def generate_leader!
      leader_class&.new
    end

    # Example: pilgim camps have a 33% chance of additionally having a sister and novices.
    def attempt_extra_gang!(characters_by_count, leaders, max_count = nil)
      return 0 unless extra_gang

      gang = extra_gang.call
      return 0 unless gang

      group_count = gang.roll_count
      if max_count.nil? || group_count + 1 <= max_count
        characters_by_count[gang.group_name] += group_count
        characters_by_count[gang.leader_title] += 1
        leaders << generate_leader!
        group_count + 1
      else
        0
      end
    end
  end
end
