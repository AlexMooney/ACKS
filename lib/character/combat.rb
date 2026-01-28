# frozen_string_literal: true

require "csv"

class Character
  module Combat
    MASTERWORK_BONUS = 1

    def combat_stats_line
      return nil unless attack_throw

      [
        "HP: #{hit_points}",
        "AC: #{armor_class} (#{best_armor} +1#{uses_shield? ? ', shield +1' : ''}#{stats.dex_bonus != 0 && %(, Dex #{stats.dex_bonus})})",
        "Melee Attack: #{melee_attack}+, #{format_damage_dice(melee_damage_bonus)}",
        "Ranged Attack: #{ranged_attack}+, #{format_damage_dice(ranged_damage_bonus)}"
      ].join(", ")
    end

    def hit_points
      @hit_points ||= begin
                        hp = 4 + stats.con_bonus
                        (level).times do
                          hp = [hp + 1, level.times.sum { roll_dice(hit_die) + stats.con_bonus }].max
                        end
                        hp
                      end
    end

    def melee_damage_bonus
      base = damage_bonus
      return nil unless base

      stats.str_bonus + base + MASTERWORK_BONUS
    end

    def ranged_damage_bonus
      base = damage_bonus
      return nil unless base

      base + MASTERWORK_BONUS
    end

    def format_damage_dice(bonus)
      return "1d6" if bonus.zero?

      bonus.positive? ? "1d6+#{bonus}" : "1d6#{bonus}"
    end

    def melee_attack
      base = attack_throw
      return nil unless base

      base - stats.str_bonus - MASTERWORK_BONUS
    end

    def ranged_attack
      base = attack_throw
      return nil unless base

      base - stats.dex_bonus - MASTERWORK_BONUS
    end

    SHIELD_CLASSES = %w[Fighter Crusader Explorer Barbarian Bard].freeze

    def uses_shield?
      SHIELD_CLASSES.include?(character_class)
    end

    def shield_ac
      uses_shield? ? (1 + MASTERWORK_BONUS) : 0
    end

    def armor_class
      base_ac + MASTERWORK_BONUS + shield_ac + stats.dex_bonus
    end
  end
end
