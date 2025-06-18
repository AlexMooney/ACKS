# frozen_string_literal: true

class Character
  module Names
    module JutlandicNames
      JUTLANDIC_SURNAME_TYPES = %w[patronym patronym patronym patronym sobriquet].freeze
      def jutlandic_name(sex)
        surnname_type = roll_table(JUTLANDIC_SURNAME_TYPES)
        surname = case surnname_type
                  when "patronym"
                    roll_table(JUTLANDIC_MALE) + (male?(sex) ? "sson" : "dottir")
                  when "sobriquet"
                    roll_table(JUTLANDIC_SOBRIQUETS)
                  end
        "#{roll_table(self.class.const_get("JUTLANDIC_#{sex.upcase}"))} #{surname}"
      end

      JUTLANDIC_MALE = {
        3 => "Asmund",
        6 => "Brardi",
        9 => "Dagr",
        12 => "Gunnar",
        15 => "Inthorn",
        18 => "Olf",
        21 => "Rannulfr",
        24 => "Sigwulf",
        27 => "Thorfin",
        30 => "Volundr",
      }.freeze
      JUTLANDIC_FEMALE = {
        3 => "Astrid",
        6 => "Brynhild",
        9 => "Dagny",
        12 => "Eira",
        15 => "Ingrid",
        18 => "Katla",
        21 => "Nessa",
        24 => "Signy",
        27 => "Thyra",
        30 => "Unnhild",
      }.freeze
      JUTLANDIC_SOBRIQUETS = [
        "the Brave",
        "the Bold",
        "Bloody-Handed",
        "Red Reaver",
        "Stormcaller",
        "Blackheart",
        "the Fair",
        "the Golden",
        "the Swift",
        "Implacable",
        "the Cunning",
        "Iceheart",
        "the Generous",
      ].freeze
    end
  end
end
