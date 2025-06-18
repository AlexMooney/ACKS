# frozen_string_literal: true

class Character
  module Names
    module OpeleneanNames
      def opelenean_name(sex)
        aurnaized = rand < 0.2
        table = self.class.const_get("OPELENEAN_#{sex.upcase}#{'_AURANIZED' if aurnaized}")
        given_name = roll_table(table)
        patronym = roll_table(self.class.const_get("OPELENEAN_MALE#{'_AURANIZED' if aurnaized}"))
        patronym = patronym.downcase if aurnaized
        attachment = male?(sex) ? "Bar" : "Bat"
        "#{given_name} #{attachment}#{' ' if aurnaized}#{patronym}"
      end

      OPELENEAN_MALE = {
        3 => "Abedsh",
        6 => "Bodash",
        9 => "Danel",
        12 => "Eshmunazar",
        15 => "Hiram",
        18 => "Juba",
        21 => "Maharbal",
        24 => "Paebel",
        27 => "Shillek",
        30 => "Uthman",
      }.freeze

      OPELENEAN_MALE_AURANIZED = {
        3 => "Abedian",
        6 => "Bodashian",
        9 => "Danelus",
        12 => "Eshmunicus",
        15 => "Hiramus",
        18 => "Jubian",
        21 => "Maharbarus",
        24 => "Paebelius",
        27 => "Shillekian",
        30 => "Uthmanian",
      }.freeze

      OPELENEAN_FEMALE = {
        3 => "Ashera",
        6 => "Elissa",
        9 => "Donatiya",
        12 => "Fahima",
        15 => "Hurriya",
        18 => "Padriya",
        21 => "Rasha",
        24 => "Sapphira",
        27 => "Talliya",
        30 => "Zahira",
      }.freeze

      OPELENEAN_FEMALE_AURANIZED = {
        3 => "Asherenia",
        6 => "Elissanna",
        9 => "Donatiyn",
        12 => "Fahina",
        15 => "Hurriyana",
        18 => "Padriyana",
        21 => "Rashara",
        24 => "Sapphara",
        27 => "Tallyanna",
        30 => "Zaharë",
      }.freeze
    end
  end
end
