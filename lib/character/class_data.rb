# frozen_string_literal: true

require "csv"

class Character
  module ClassData
    def class_data_table
      @class_data_table ||= load_class_armor_table
    end

    def fetch_data(key)
      result = class_data_table.dig(character_class.downcase, key) || class_data_table.dig(class_type, key)
      raise "No class data found for #{character_class.downcase} or #{class_type}" unless result

      result
    end

    def hit_die
      fetch_data(:hit_die)
    end

    def base_ac
      fetch_data(:base_ac)
    end

    def best_armor
      fetch_data(:best_armor)
    end

    def max_armor_type
      fetch_data(:max_armor_type)
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
          base_ac: row["base_ac"].to_i,
        }
      end
      result
    end
  end
end
