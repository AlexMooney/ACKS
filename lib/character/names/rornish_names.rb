# frozen_string_literal: true

class Character
  module Names
    module RornishNames
      def rornish_name(sex)
        aurnaized = rand < 0.4
        table = self.class.const_get("RORN_#{sex.upcase}#{'_AURANIZED' if aurnaized}")
        given_name = roll_table(table)
        surname = roll_table(table)
        "#{given_name} #{surname}"
      end

      RORN_MALE = {
        3 => "Aeron",
        6 => "Braig",
        9 => "Caradoc",
        12 => "Georn",
        15 => "Mard",
        18 => "Owain",
        21 => "Roben",
        24 => "Stuarry",
        27 => "Theon",
        30 => "Urien",
      }.freeze
      RORN_MALE_AURANIZED = {
        3 => "Aeronus",
        6 => "Braigius",
        9 => "Caradocian",
        12 => "Geornius",
        15 => "Mardorus",
        18 => "Owainus",
        21 => "Robenus",
        24 => "Stuarus",
        27 => "Theonius",
        30 => "Urienus",
      }.freeze
      RORN_FEMALE = {
        3 => "Anwen",
        6 => "Ceridwen",
        9 => "Deiresa",
        12 => "Eirwen",
        15 => "Katrist",
        18 => "Maranie",
        21 => "Nimue",
        24 => "Rachess",
        27 => "Seren",
        30 => "Vale",
      }.freeze
      RORN_FEMALE_AURANIZED = {
        3 => "Anwenia",
        6 => "Ceridwenia",
        9 => "Deiresta",
        12 => "Eirwenia",
        15 => "Katrista",
        18 => "Marania",
        21 => "Nimua",
        24 => "Rachessa",
        27 => "Serenia",
        30 => "Valea",
      }.freeze
    end
  end
end
