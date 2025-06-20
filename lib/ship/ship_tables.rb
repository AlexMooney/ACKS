# frozen_string_literal: true

class Ship
  module ShipTables
    RANDOM_FLAG_SYRNASOS = { # TODO: name generation
      2 => "Northern Argollëan",
      3 => "Rornish",
      4 => "Corcanoan",
      5 => "Jutlandic",
      6 => "Celdorean",
      7 => "Syrnasan",
      8 => "Opelenean",
      9 => "Nicean",
      10 => "Kemeshi",
      11 => "Somirean",
      12 => "Tirenean",
    }.freeze

    require_relative "../merchant_mariners"
    PASSENGER_TYPE_BY_ROLL = {
      6 => Commoners,
      9 => Pilgrims,
      10 => Marines,
    }.freeze

    MERCHANT_CAPTAIN_CLASS_TABLE = {
      10 => "Venturer",
      12 => "Explorers",
      14 => "Fighter",
      16 => "Thief",
      18 => "Bard",
      19 => "Barbarian",
      20 => nil,
    }.freeze

    NAVAL_CAPTAIN_CLASS_TABLE = {
      11 => "Fighter",
      15 => "Explorers",
      16 => "Venturer",
      17 => "Thief",
      18 => "Bard",
      19 => "Barbarian",
      20 => nil,
    }.freeze
  end
end
