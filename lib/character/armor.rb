# frozen_string_literal: true

require "csv"

class Character
  class Armor
    class << self
      def class_armor_table
        @class_armor_table ||= load_class_armor_table
      end

      def base_ac(character_class)
        class_armor_table.dig(character_class.to_s.capitalize, :base_ac)
      end

      def best_armor(character_class)
        class_armor_table.dig(character_class.to_s.capitalize, :best_armor)
      end

      def max_armor_type(character_class)
        class_armor_table.dig(character_class.to_s.capitalize, :max_armor_type)
      end

      private

      def load_class_armor_table
        result = {}
        path = File.expand_path("class_armor.csv", __dir__)
        CSV.foreach(path, headers: true) do |row|
          result[row["class"]] = {
            max_armor_type: row["max_armor_type"],
            best_armor: row["best_armor"],
            base_ac: row["base_ac"].to_i
          }
        end
        result
      end
    end
  end
end
