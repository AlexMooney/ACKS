# frozen_string_literal: true

class Character
  module Names
    include ArgolleanNames
    include CeldoreanNames
    include JutlandicNames
    include KemeshiNames
    include NiceanNames
    include OpeleneanNames
    include RornishNames
    include SomireanNames
    include SyrnasanNames
    include TireneanNames
    include ZaharanNames

    def random_name(ethnicity, sex)
      case ethnicity.downcase
      when "celdorean"
        celdorean_name(sex)
      when "jutlandic"
        jutlandic_name(sex)
      when "kemeshi"
        kemeshi_name(sex)
      when "nicean"
        nicean_name(sex)
      when "northern argollëan"
        argollean_name(sex)
      when "opelenean"
        opelenean_name(sex)
      when "rornish"
        rornish_name(sex)
      when "somirean"
        somirean_name(sex)
      when "syrnasan"
        syrnasan_name(sex)
      when "tirenean", "corcanoan"
        tirenean_name(sex)
      when "zaharan"
        zaharan_name(sex)
      else # TODO: krysean kushtu shebatean skysos
        "Not Implemented (#{ethnicity})"
      end
    end

    private

    def vowel_ending?(name)
      name[-1].match?(/[aeiou]/i)
    end

    def male?(sex_string)
      sex_string.downcase.start_with? "m"
    end
  end
end
