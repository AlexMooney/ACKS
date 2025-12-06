# frozen_string_literal: true

require "csv"

module MagicItems
  class Potions
    include SpellCheck

    def appearance_by_potion(potion, chance_of_different_appearance: true)
      potion = spell_check(clean_potion_name(potion), potion_spelling_keys, spell_checker:)
      appearance = appearance_csv[potion.downcase] || "(unknown appearance)"
      if chance_of_different_appearance && rand < 0.15
        appearance = "#{appearance_csv.values.sample} (different appearance)"
      end
      while appearance.start_with? "(as potion imitated)"
        appearance = appearance_csv.values.sample
      end
      appearance
    end

    private
    
    def appearance_csv
      @appearance_by_potion ||= CSV.parse(File.read(File.expand_path("potion_appearances.csv", __dir__)), headers: true)
        .each_with_object({}) do |line, result|
          result[clean_potion_name(line["potion"])] = line["appearance"]
        end
    end

    def clean_potion_name(potion)
      potion.downcase.sub(/\W\z/, "")
    end

    def potion_spelling_keys
      @potion_spelling_keys ||= begin
                           keys = appearance_csv.keys
                           keys.select { |k| k.include? "," }.each do |k|
                             keys << k.split(",").map(&:strip).reverse.join(" ")
                           end
                           keys
                       end
    end

    def spell_checker
      @spell_checker ||= DidYouMean::SpellChecker.new(dictionary: potion_spelling_keys)
    end
  end
end
