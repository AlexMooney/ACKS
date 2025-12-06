# frozen_string_literal: true

require "csv"

require_relative "monsters"
require_relative "wilderness_monster"

class Terrain
  include Tables

  TERRAIN_TYPES = %w[
    barrens_rocky
    barrens_tundra
    desert_any
    forest_deciduous
    forest_tiaga
    grassland_farmland
    grassland_savana
    grassland_steppe
    hills_any
    jungle_any
    mountains_forested
    mountains_snowy
    mountains_volcanic
    river_desert
    river_other
    scrubland_dense
    scrubland_sparse
    swamp_any
    sea_monster
    sea_civilized
  ].freeze # TODO: deal with river_jungle which uses same monsters but different civilized

  attr_reader :name, :table_by_rarity, :missing_monsters

  def self.load_all!
    # each terrain has a CSV in ./encounter_tables
    Dir.glob("encounter_tables/*.csv").map do |csv_file|
      Terrain.new(File.basename(csv_file, ".csv"), csv_file)
    end
  end

  def initialize(name)
    @name = name
    @table_by_rarity = {}
    @missing_monsters = []
    read_csv!
  end

  def average_quantity(rarity, quantity)
    send(rarity).map(&method(:find_monster)).map(&quantity).sum / send(rarity).size
  end

  def random_monster(rarity)
    roll_table(table_by_rarity.fetch(rarity))
  end

  NAME_TWEAKS = {
    "Acanthaspis" => "Acanthaspis, Giant",
    "Bat, Giant Vampiric" => "Bat, Giant Vampire",
    "Bee, Giant" => "Bee, Giant Killer",
    "Bee. Giant" => "Bee, Giant Killer",
    "Dolphin" => "Dolphin, Common",
    "Elementa, Major Fire" => "Elemental, Major Fire",
    "Equine, Med. Horse (wild horse)" => "Equine, Medium Horse",
    "Faeroe. Redcap" => "Faerie, Redcap",
    "Genie*" => "Genie (roll 1d4 for type)",
    "Ostrich" => "Ostrich, Common",
    "Rhinoceros" => "Rhinoceros, Common",
    "Rhinoceros (black rhino)" => "Rhinoceros, Common",
    "Rhinoceros, Woolly" => "Rhinoceros, Wooly",
    "Snake, Adder" => "Snake, King Cobra",
    "Snake, Giant Constrict. Viper" => "Snake, Giant Const. Viper",
    "Snake, Viper*" => "Snake, Viper",
    "Snake, Pit Viper" => "Snake, Viper",
    "Spectre" => "Specter",
    "Spider, Crab Spider" => "Spider, Crab",
    "Titan, Leser" => "Titan, Lesser",
    "Vampire" => "Vampire (9 HD)",
    "Wolf (golden wolf)" => "Wolf, Common",
    "Wolf (grey wolf)" => "Wolf, Common",
    "Wolf, Dire Riding" => "Wolf, Dire",
  }.freeze
  ANIMAL_EQUIVALENTS = {
    "Dog, Light Sled" => "Dog, Hunting",
    "Dog, Heavy Sled" => "Dog, War",
    "Faerie, Rusalka" => "Faerie, Nixie",
    "Snake, Black Desert Cobra" => "Snake, King Cobra",
    "Snake, Giant Sand Boa" => "Snake, Python",
    "Snake, Puff Adder" => "Snake, Viper",
    "Snake, Bush Viper" => "Snake, Viper",
    "Snake, Giant Smooth" => "Snake, Python",
    "Snake, Giant Adder" => "Snake, King Cobra",
    "Snake, Green Mamba" => "Snake, King Cobra",
    "Snake, Giant Steppe Ratsnake" => "Snake, Python",
    "Snake, Gaboon Viper" => "Snake, King Cobra",
    "Snake, Forest Cobra" => "Snake, Spitting Cobra",
    "Snake, Blunt-Nosed Viper" => "Snake, King Cobra",
    "Snake, Asp" => "Snake, Viper",
    "Snake, Asp " => "Snake, Viper",
    "Snake, Adder" => "Snake, King Cobra",
    "Varmint, Giant Birch Mouse" => "Varmint, Giant Rat",
    "Varmint, Giant Snow Vole" => "Varmint, Giant Rat",
    "Varmint, Giant Stoat" => "Varmint, Giant Weasel",
    "Varmint, Giant Wolverine" => "Varmint, Giant Weasel",
    "Zebra" => "Equine, Light Horse",
  }.freeze

  private

  def find_monster(monster_name)
    monster = WILDERNESS_MONSTER_BY_NAME[monster_name]
    monster ||= WILDERNESS_MONSTER_BY_NAME[monster_name.split(" (").first]
    monster ||= monster_name.start_with?("Dragon,") ? WILDERNESS_MONSTER_BY_NAME["Dragon"] : nil
    monster ||= monster_name.end_with?(", Giant") ? WILDERNESS_MONSTER_BY_NAME[monster_name.sub(", Giant", "")] : nil
    monster ||= WILDERNESS_MONSTER_BY_NAME[monster_name.sub(", Vampiric", " Vampire")]
    monster ||= WILDERNESS_MONSTER_BY_NAME[monster_name.sub("Men", "Man")]
    monster ||= WILDERNESS_MONSTER_BY_NAME[monster_name.sub(/\z/, "s")]
    monster ||= WILDERNESS_MONSTER_BY_NAME[monster_name.sub(/s\z/, "")]
    monster ||= WILDERNESS_MONSTER_BY_NAME[NAME_TWEAKS[monster_name]]
    monster ||= WILDERNESS_MONSTER_BY_NAME[ANIMAL_EQUIVALENTS[monster_name.sub(/\*.*/, "")]]
    monster ||= monster_name.start_with?("Herd Animal, Sm") ? WILDERNESS_MONSTER_BY_NAME["Herd Animal, Small"] : nil
    monster ||= monster_name.start_with?("Herd animal, Med") ? WILDERNESS_MONSTER_BY_NAME["Herd Animal, Medium"] : nil
    monster ||= monster_name.start_with?("Herd Animal, Med") ? WILDERNESS_MONSTER_BY_NAME["Herd Animal, Medium"] : nil
    monster ||= monster_name.start_with?("Swarm") ? WILDERNESS_MONSTER_BY_NAME["Swarm, Insect"] : nil

    if monster
      monster
    else
      missing_monsters << monster_name
      WildernessMonster.new(name: monster_name, total_xp: 0, total_spoils_value: 0, treasure_type: "Missing Monster")
    end
  end

  def read_csv!
    CSV.foreach(File.expand_path("encounter_tables/#{name}.csv", __dir__), headers: true) do |row|
      roll_header = "Roll (1d100)"
      roll = row[roll_header].split("-").last.to_i
      (row.headers - [roll_header]).each do |rarity|
        rarity_label = rarity.downcase.gsub(" ", "_")
        table_by_rarity[rarity_label] ||= {}
        table_by_rarity[rarity_label][roll] = row[rarity]
      end
    end
  end
end
