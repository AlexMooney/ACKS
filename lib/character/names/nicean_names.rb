# frozen_string_literal: true

class Character
  module Names
    module NiceanNames
      NICEAN_SURNAME_TYPES = %w[patronym patronym patronym origin origin sobriquet].freeze

      PATRONYM_CONSONANT_SUFFIXES = %w[adis akis atos ides].freeze

      NICEAN_MALE = {
        3 => "Apollonis",
        6 => "Basilio",
        9 => "Damanos",
        12 => "Iannis",
        15 => "Klenos",
        18 => "Metoros",
        21 => "Peristo",
        24 => "Spyros",
        27 => "Thales",
        30 => "Vason",
      }.freeze # TODO: Add more names

      NICEAN_FEMALE = {
        3 => "Acandra",
        6 => "Bassida",
        9 => "Daphyra",
        12 => "Eliona",
        15 => "Iandra",
        18 => "Neoma",
        21 => "Olyma",
        24 => "Selene",
        27 => "Thena",
        30 => "Zene",
      }.freeze # TODO: Add more names

      ORIGIN_CITIES = {
        5 => "Pireus",
        6 => "Trikala",
        7 => "Thessaloniki",
        8 => "Karditsa",
        9 => "Larissa",
        10 => "Volos",
        11 => "Elassona",
        12 => "Tyrnavos",
      }.freeze

      NICEAN_SOBRIQUETS = [
        "Golden-Tongued",
        "the Brave",
        "the Cunning",
        "the Wise",
        "the Strong",
        "the Swift",
        "Dragonbane",
        "Stormcaller",
        "the Quiet",
        "Ironfist",
        "Lightbringer",
        "Golden-Handed",
      ].freeze

      def nicean_name(sex)
        table = self.class.const_get("NICEAN_#{sex.upcase}")
        surname_type = roll_table(NICEAN_SURNAME_TYPES)
        surname = case surname_type
                  when "patronym"
                    surname = roll_table(NICEAN_MALE)
                    suffix = vowel_ending?(surname) ? "poulos" : PATRONYM_CONSONANT_SUFFIXES.sample
                    "#{surname}#{suffix}"
                  when "origin"
                    roll_table(ORIGIN_CITIES)
                  when "sobriquet"
                    roll_table(NICEAN_SOBRIQUETS)
                  end
        "#{roll_table(table)} #{surname}"
      end
    end
  end
end
