# frozen_string_literal: true

require "csv"

class Character
  class AttackThrows
    class << self
      def table
        @table ||= load_table
      end

      def lookup(character_class, level)
        key = [character_class.to_s.capitalize, level.to_i]
        table[key]
      end

      def attack_throw(character_class, level)
        lookup(character_class, level)&.fetch(:attack_throw)
      end

      def saving_throws(character_class, level)
        data = lookup(character_class, level)
        return nil unless data

        data.slice(:paralysis, :death, :blast, :implements, :spells)
      end

      def classes
        @classes ||= table.keys.map(&:first).uniq
      end

      def damage_bonus(character_class, level)
        lookup(character_class, level)&.fetch(:damage_bonus)
      end

      private

      def load_table
        result = {}
        path = File.expand_path("attack_throws.csv", __dir__)
        CSV.foreach(path, headers: true) do |row|
          key = [row["class"], row["level"].to_i]
          result[key] = {
            paralysis: row["paralysis"].to_i,
            death: row["death"].to_i,
            blast: row["blast"].to_i,
            implements: row["implements"].to_i,
            spells: row["spells"].to_i,
            attack_throw: row["attack_throw"].to_i,
            damage_bonus: row["damage_bonus"].to_i
          }
        end
        result
      end
    end
  end
end
