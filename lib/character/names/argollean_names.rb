# frozen_string_literal: true

class Character
  module Names
    module ArgolleanNames
      def argollean_name(sex)
        table = self.class.const_get("ARGOLLEAN_#{sex.upcase}")
        given_name = roll_table(table)
        "#{given_name} #{ADJECTIVES.sample}#{NOUNS.sample}"
      end

      ARGOLLEAN_MALE = %w[Aodan Brogan Caoimhin Eadan Fionntan Mainchin Orthanach Rigan Seanan Tomman].freeze
      ARGOLLEAN_FEMALE = %w[Arial Ceara Dairinn Enya Irial Mornya Niamh Riona Saorla Una].freeze
      ADJECTIVES = %w[Silver Gold Bright Brave Swift Fierce Wise].freeze
      NOUNS = %w[leaf hair eyes tree river sea cloud wind rain].freeze
    end
  end
end
