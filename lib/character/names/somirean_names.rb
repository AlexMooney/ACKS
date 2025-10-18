# frozen_string_literal: true

class Character
  module Names
    module SomireanNames
      SOMIREAN_SURNAME_TYPE = %w[
        noble profession profession profession profession profession villiage villiage patronym patronym patronym
      ].freeze
      SOMIREAN_MALE = {
        3 => "Artashumara",
        6 => "Bindusara",
        9 => "Kumara",
        12 => "Mahinda",
        15 => "Narasimha",
        18 => "Puru",
        21 => "Rama",
        24 => "Vardhana",
        27 => "Xandrama",
        30 => "Yashodharman",
      }.freeze
      SOMIREAN_FEMALE = {
        3 => "Asmali",
        6 => "Devita",
        9 => "Havati",
        12 => "Kavasha",
        15 => "Nitama",
        18 => "Preena",
        21 => "Skandara",
        24 => "Tadukhepa",
        27 => "Vashi",
        30 => "Yavi",
      }.freeze
      SOMIREAN_NOBLE = [SOMIREAN_MALE, SOMIREAN_MALE, SOMIREAN_MALE, SOMIREAN_FEMALE].freeze
      SOMIREAN_NOBLE_SUFFIX = %w[ja yata].freeze
      SOMIREAN_PROFESSIONS = %w[
        Apothecary Armorer Baker Blacksmith Bookbinder Bowyer Fletcher Brewer Brickmaker Butcher Cabinetmaker
        Candlemaker Capper Hatter Carpenter Chaloner Tapicer Clothmaker Cobbler Cordwainer Confectioner Cooper
        Coppersmith Corder Ropemaker Florist Gemcutter Glassworker Goldsmith Hornworker Illuminator Jeweler Locksmith
        Mason Parchmentmaker Perfumer Potter Saddler Fuster Scribe Shipwright Silversmith Spinner Tailor Seamstress
        Tanner Tawer Taxidermist Tinker Toymaker Wainwright Weaponsmith Wheelwright
        Bookseller Chandler Upholder Coppermonger Cornmonger Draper Fishmonger Fripperer Furrier Greengrocer Horsemonger
        Ironmonger Lawyer Lumbermonger Mercer Oilmonger Peltmonger Skinner Poulterer Salter Pepperer Vintner
        Cantinakeeper Innkeeper Tavernkeeper Brothelkeeper
        Barber Masseuse Bricklayer Cook Dockworker Fuller Launderer Gondolier Rower Streetcleaner Hawker Hostler
        Stablehand Ratcatcher Roofer Tiler Sailor Fisher Sawyer Woodcutter Teamster
        Alchemist Trainer Artillerist Engineer Healer Physicker Chirugeon Marshal Navigator Quartermaster Sage Scout
      ].freeze
      SOMIREAN_VILLAGES = %w[
        Ardana Bithama Keshara Lathara Mardana Neshara Odama Prathara Rathama Skashara Tarama Vadusama Yashara
      ].freeze
      def somirean_name(sex)
        surname_type = roll_table(SOMIREAN_SURNAME_TYPE)
        surname = case surname_type
                  when "noble"
                    "#{roll_table(SOMIREAN_NOBLE)}#{roll_table(SOMIREAN_NOBLE_SUFFIX)}"
                  when "profession"
                    roll_table(SOMIREAN_PROFESSIONS)
                  when "villiage"
                    "of #{roll_table(SOMIREAN_VILLAGES)}"
                  when "patronym"
                    "#{male?(sex) ? 'son' : 'daughter'} of #{roll_table(SOMIREAN_MALE)}"
                  end
        given_name = roll_table(self.class.const_get("SOMIREAN_#{sex.upcase}"))
        "#{given_name} #{surname}"
      end
    end
  end
end
