# frozen_string_literal: true

require "csv"

class Character
  module ClassThrows
    def table
      @table ||= load_table
    end

    def lookup
      key = [character_class, level]
      table[key]
    end

    def attack_throw
      lookup&.fetch(:attack_throw)
    end

    def saving_throws
      lookup&.slice(:paralysis, :death, :blast, :implements, :spells)
    end

    def damage_bonus
      lookup&.fetch(:damage_bonus)
    end

    private

    def load_table
      result = {}
      path = File.expand_path("class_throws.csv", __dir__)
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
