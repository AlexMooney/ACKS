# frozen_string_literal: true

class Character
  module Names
    module SyrnasanNames
      SYRNASAN_SURNAME_TYPES = %w[patronym patronym patronym patronym origin].freeze
      SYRNASAN_ORIGIN_CITIES = {
        8 => "Emprisos",
        10 => "Armatusia",
        12 => "Dasantilla",
        14 => "Barduria",
        16 => "Varro",
        18 => "Darmorca",
        20 => "Blaedarum",
        21 => "Bindusia",
        22 => "Cralusia",
      }.freeze

      def syrnasan_name(sex)
        surname_type = roll_table(SYRNASAN_SURNAME_TYPES)
        surname = case surname_type
                  when "patronym"
                    roll_table(self.class.const_get("SYRNASAN_MALE"))
                  when "origin"
                    roll_table(SYRNASAN_ORIGIN_CITIES)
                  end
        "#{roll_table(self.class.const_get("SYRNASAN_#{sex.upcase}"))} #{surname}"
      end

      SYRNASAN_MALE = %w[
        Andio Aran Arbo Armatus Bagaron Ballaios Bardurius Bato Blaedarus Bindus Bounon Bulsinus Callo Carius Cralus
        Derbanoi Darmorcus Dasmenus Dasas Dasius Dazas Dasto Dizeros Drenis Dard Labrico Lensus Liccaius Lirus Mag
        Medaurus Naro Pelso Plassarus Platino Plator Precio Sabaius Surco Temans Tergitio Ulk Varro Vendum Verzo
        Verzulus Vidasus Volcos
      ].freeze
      SYRNASAN_FEMALE = %w[
        Andena Aria Arba Bagara Balla Bilia Barba Bata Boria Brisa Calla Caria Darda Dasa Daza Delme Ditus Domator
        Glaukias Labrica Licca Maga Mantia Nara Pelsa Pinnes Platina Precia Sabaia Scerdilaidas Sentona Sibyna Sica
        Surca Tatta Teuta Tergitia Thika Vara Verza
      ].freeze
    end
  end
end
