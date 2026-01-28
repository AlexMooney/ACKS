# frozen_string_literal: true

require "csv"

class Character
  module ClassData
    def class_data_table
      @class_data_table ||= load_class_armor_table
    end

    def hit_die
      class_data_table.dig(character_class, :hit_die)
    end

    def base_ac
      class_data_table.dig(character_class, :base_ac)
    end

    def best_armor
      class_data_table.dig(character_class, :best_armor)
    end

    def max_armor_type
      class_data_table.dig(character_class, :max_armor_type)
    end

    private

    def load_class_armor_table
      result = {}
      path = File.expand_path("class_data.csv", __dir__)
      CSV.foreach(path, headers: true) do |row|
        result[row["class"]] = {
          hit_die: row["hit_die"],
          max_armor_type: row["max_armor_type"],
          best_armor: row["best_armor"],
          base_ac: row["base_ac"].to_i
        }
      end
      result
    end
  end
end
