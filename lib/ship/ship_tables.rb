# frozen_string_literal: true

class Ship
  module ShipTables
    # TODO: ship name generation
    RANDOM_FLAG_SYRNASOS = {
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

    RANDOM_FLAG_CELDOREA = {
      2 => "Northern Argollëan",
      3 => "Rornish",
      4 => "Jutlandic",
      5 => "Somirean",
      8 => "Celdorean",
      9 => "Syrnasan",
      10 => "Opelenean",
      11 => "Kemeshi",
      12 => "Nicean",
    }.freeze

    require_relative "../merchant_mariners"
    PASSENGER_TYPE_BY_ROLL = {
      6 => Commoners,
      9 => Pilgrims,
      10 => Marines,
    }.freeze

    MERCHANT_CAPTAIN_CLASS_TABLE = {
      10 => "Venturer",
      12 => "Explorer",
      14 => "Fighter",
      16 => "Thief",
      18 => "Bard",
      19 => "Barbarian",
      20 => nil,
    }.freeze

    NAVAL_CAPTAIN_CLASS_TABLE = {
      11 => "Fighter",
      15 => "Explorer",
      16 => "Venturer",
      17 => "Thief",
      18 => "Bard",
      19 => "Barbarian",
      20 => nil,
    }.freeze

    PIRATE_CAPTAIN_CLASS_TABLE = {
      8 => "Fighter",
      11 => "Barbarian",
      14 => "Explorer",
      15 => "Ruingaurd",
      16 => "Venturer",
      20 => nil,
    }.freeze
  end
end
