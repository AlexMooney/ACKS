# frozen_string_literal: true

DungeonMonster = Struct.new(
  "DungeonMonster", :floor, :native_level, :name, :num_no_lair, :num_lair, :lair_chance, :treasure_type
) do
  attr_accessor :lair, :number_appearing

  def to_s
    "#{number_appearing} #{name} #{lair ? 'lair' : ''} #{treasure}".squeeze(" ").strip
  end

  def number_appearing
    @number_appearing ||=
      if lair && lairs_in_gangs?
        num_gangs = roll_dice_with_level_modifier(num_lair)
        if floor.empty_rooms.count >= num_gangs - 1
          floor.empty_rooms.each_with_index do |room, index|
            break if index >= num_gangs - 1

            room.type = :monster
            room.monster = DungeonMonster.new(floor, floor.level, "#{name} gang").tap do |m| # more gangs, not bigger gangs
              m.number_appearing = roll_dice(num_no_lair)
              m.lair = false
            end
          end
          "Lair of #{num_gangs} gangs with #{roll_dice(num_no_lair)}"
        else # not enough empty rooms for gangs
          @lair = false
          roll_dice_with_level_modifier(num_no_lair)
        end
      elsif lair
        roll_dice_with_level_modifier(num_lair)
      else
        roll_dice_with_level_modifier(num_no_lair)
      end
  end

  def roll_dice_with_level_modifier(dice_string)
    result = roll_dice(dice_string)
    if floor.level > native_level
      result *= 1.5**(floor.level - native_level)
    elsif floor.level < native_level
      result *= 0.5**(native_level - floor.level)
    end
    [1, result].max.round(half: :even)
  end

  def roll_dice(dice_string)
    dice_string.sub("*", "").gsub(/\s/, "").split("+").sum do |fragment|
      number, sides = fragment.split("d").map(&:to_i)
      if sides
        number.times.map { rand(1..sides) }.sum
      else
        number
      end
    end
  end

  def lair
    @lair = if @lair.nil? && lair_chance
              rand < lair_chance
            else
              @lair
            end
  end

  def lairs_in_gangs?
    num_lair&.end_with?("*")
  end

  def treasure
    "treasure #{treasure_type}" if lair && treasure_type
  end

  def <=>(other)
    if name == other.name
      case [number_appearing.class, other.number_appearing.class]
      when [String, String], [Integer, Integer]
        number_appearing <=> other.number_appearing
      when [String, Integer]
        -1
      when [Integer, String]
        1
      else
        raise "Unexpected comparison: #{number_appearing.class} <=> #{other.number_appearing.class}"
      end
    else
      name <=> other.name
    end
  end
end

DUNGEON_MONSTERS = {
  1 => # [DungeonMonster name,   no lair #,  lair #, lair chance, treasure type]
  { 1 => ["Goblin",           "2d4",  "2d6*",  0.4,  "E"],
    2 => ["Kobold",           "4d4",  "1d6*",  0.4,  "E"],
    3 => ["Morlock",          "1d12", "1d8*",  0.35, "E"],
    4 => ["Orc",              "2d4",  "2d6*",  0.35, "G"],
    5 => ["Beetle, Luminous", "1d8",  "2d6",   0.4],
    6 => ["Centipede, Giant", "2d4",  "2d12",  0.1],
    7 => ["Ferret, Giant",    "1d8",  "1d12",  0.25, "A"],
    8 => ["Rat, Giant",       "3d6",  "3d10",  0.1,  "A"],
    9 => ["Men, Brigand",     "2d4",  "1d10*", 0.2,  "H"],
    10 => ["Skeleton",        "3d4",  "3d10",  0.35],
    11 => ["Strix",           "1d10", "3d12",  0.4, "F"],
    12 => ["NPC Party Lvl 1", "1d4+2", "1*",   0] },
  2 =>
  { 1 => ["Gnoll",                  "1d6", "2d6*", 0.2, "G"],
    2 => ["Hobgoblin",              "1d6", "1d8*", 0.25, "E"],
    3 => ["Lizardman",              "2d4", "1d8*", 0.3,  "L"],
    4 => ["Troglydyte",             "1d8", "1d10*", 0.15, "J"],
    5 => ["Bat, Giant",             "1d10", "1d10", 0.35],
    6 => ["Fly, Giant Carnivorous", "1d8", "2d6", 0.35, "C"],
    7 => ["Locust, Cavern",         "1d10", "2d10", 0.3],
    8 => ["Snake, Pit Viper",       "1d8"],
    9 => ["Ghoul, Grave",           "1d6", "2d8", 0.2, "E"],
    10 => ["Men, Berserker",        "1d6", "1d8*", 0.2, "J"],
    11 => ["Zombie",                "2d4", "4d6", 0.35],
    12 => ["NPC Party Lvl 2",       "1d4+2", "1*", 0] },
  3 =>
  { 1 => ["Bugbear",               "2d4", "1d4*", 0.25, "L"],
    2 => ["Lycanthrope, Werewolf", "1d6", "2d6", 0.25, "J"],
    3 => ["Ogre",                  "1d6", "1d3*", 0.2, "J and special"],
    4 => ["Hobgholl",              "1d6", "1d10", 0.35, "G"],
    5 => ["Ant, Giant",            "2d4", "4d6", 0.1, "I and special"],
    6 => ["Lizard, Giant Draco",   "1d3", "1d6", 0.25],
    7 => ["Scorpion, Giant",       "1d6", "1d6", 0.5],
    8 => ["Wolf, Dire",            "1d4", "2d4", 0.1],
    9 => ["Carrion Horror",        "1d3", "1d3", 0.25],
    10 => ["Gargoyle",             "1d6", "2d4", 0.2, "J"],
    11 => ["Ghoul, Marsh",         "1d10", "2d4*", 0.35, "N"],
    12 => ["NPC Party Lvl 4",      "1d4+2", "1*", 0] },
  4 =>
  { 1 => ["Lycanthrope, Wereboar",          "1d4", "2d4", 0.2, "J"],
    2 => ["Lycanthrope, Weretiger",         "1d4", "1d4", 0.15, "J"],
    3 => ["Minotaur",                       "1d6", "1d8", 0.2, "L,G"],
    4 => ["Attercop, Monsterous",           "1d3", "1d3", 0.7, "F"],
    5 => ["Boar, Giant",                    "1d4", "1d4", 0.25],
    6 => ["Owlbeast",                       "1d4", "1d4", 0.3, "I"],
    7 => ["Acanthaspis, Giant",             "1d6", "1d8", 0.15, "I"],
    8 => ["Snake, Giant Python",            "1d4", "1d4", 0.2],
    9 => ["Lizard, Giant Horned Chameleon", "1d3", "1d6", 0.25],
    10 => ["Medusa",                        "1d3", "1d4", 0.5, "H"],
    11 => ["Mass, Gelatinous",              "1", "1", 1.0, "C,A"],
    12 => ["NPC Party Lvl 5",               "1d4+2", "1*", 0] },
  5 =>
  { 1 => ["Ettin",               "1d2", "1d4", 0.2, "N,H"],
    2 => ["Giant, Hill",         "1d4", "2d4", 0.25, "N"],
    3 => ["Giant, Stone",        "1d3", "1d6", 0.25, "N"],
    4 => ["Troll",               "1d8", "1*", 0.4, "O"],
    5 => ["Arane",               "1",   "1d3", 0.7, "J"],
    6 => ["Worm, Great Ice",     "1",   "1d6", 0.25, "P"],
    7 => ["Basilisk",            "1d6", "1d6", 0.4, "P"],
    8 => ["Hell Hound, Greater", "2d4", "2d4", 0.3, "P"],
    9 => ["Salamander, Flame",   "1d4+1", "2d4", 0.25, "Q"],
    10 => ["Specter",            "1d4", "1d8", 0.2, "N,N"],
    11 => ["Wyvern",             "1d2", "1d6", 0.3, "M"],
    12 => ["NPC Party Lvl 8",    "1d4+3", "1*", 0] },
  6 =>
  { 1 => ["Level 6 monster", "1", "1d4", 0.2, "R"] },
}.freeze

# rubocop:disable Naming/VariableName
_CIVILIZED_BARRENS = [
  "Camel",
  "Camel",
  "Herd Animal, Small (sheep)",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Commoner (shepherds)",
  "Man, Commoner (shepherds)",
  "Man, Commoner (shepherds)",
  "Man, Commoner (shepherds)",
  "Man, Merchant",
  "Man, Merchant",
  "Man, Nomads",
  "Man, Nomads",
  "Man, Nomads",
  "Man, Nomads",
  "Man, Patroller (camel lancers)",
  "Man, Patroller (camel lancers)",
  "Man, Pilgrim",
  "Man, Pilgrim",
  "Ghoul, Desert",
].freeze
_CIVILIZED_GRASS = [
  "Equine, Horse (light or steppe)",
  "Herd Animal, Large (cattle)",
  "Herd Animal, Small (goat)",
  "Herd Animal, Small (sheep)",
  "Herd Animal, Small (sheep)",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Commoner (farmers)",
  "Man, Commoner (farmers)",
  "Man, Commoner (farmers)",
  "Man, Commoner (shepherds)",
  "Man, Merchant",
  "Man, Merchant",
  "Man, Merchant",
  "Man, Merchant",
  "Man, Patroller (med. cavalry)",
  "Man, Patroller (med. cavalry)",
  "Man, Pilgrim",
  "Man, Pilgrim",
  "Devil Boar",
].freeze
_CIVILIZED_SAVANNA = [
  "Herd Animal, Lg. (wildebeest)",
  "Herd Animal, Med. (impala)",
  "Herd Animal, Small (gazelle)",
  "Herd Animal, Small (gazelle)",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Commoner (farmers)",
  "Man, Commoner (farmers)",
  "Man, Merchant",
  "Man, Merchant",
  "Man, Patroller (med. cav.)",
  "Man, Patroller (med. cav.)",
  "Man, Pilgrim",
  "Man, Pilgrim",
  "Man, Tribal Warrior",
  "Man, Tribal Warrior",
  "Man, Tribal Warrior",
  "Man, Tribal Warrior",
  "Neanderthals",
  "Lycan., Weretiger",
].freeze
_CIVILIZED_FOREST = [
  "Boar, Common",
  "Herd Animal, Med. (deer)",
  "Herd Animal, Med. (deer)",
  "Man, Bandit",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Brigand",
  "Man, Berserker",
  "Man, Commoner (farmers)",
  "Man, Commoner (farmers)",
  "Man, Merchant",
  "Man, Patroller (bow)",
  "Man, Pilgrim",
  "Elf",
  "Elf",
  "Elf",
  "Elf",
  "Gnome",
  "Gnome",
  "Lycan., Werebear",
].freeze
_CIVILIZED_TIAGA = [
  "Boar, Common",
  "Herd Animal, Large (elk)",
  "Herd Animal, Small (reindeer)",
  "Herd Animal, V. Large (wisent)",
  "Man, Bandit",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Brigand",
  "Man, Commoner (farmers)",
  "Man, Commoner (farmers)",
  "Man, Commoner (shepherds)",
  "Man, Commoner (shepherds)",
  "Man, Merchant",
  "Man, Patroller (bowmen)",
  "Man, Pilgrim",
  "Man, Raider",
  "Man, Raider",
  "Elf",
  "Elf",
  "Lycan., Werewolf",
].freeze
_CIVILIZED_HILLS = [
  "Equine, Donkey",
  "Herd Animal, Small (goat)",
  "Man, Bandit",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Brigand",
  "Man, Merchant",
  "Man, Commoner (shepherds)",
  "Man, Commoner (shepherds)",
  "Man, Commoner (shepherds)",
  "Man, Commoner (shepherds)",
  "Man, Patroller (bowmen)",
  "Man, Patroller (bowmen)",
  "Man, Pilgrim",
  "Man, Raider",
  "Dwarf",
  "Dwarf",
  "Gnome",
  "Halfling",
  "Lycan., Wereboar",
].freeze
_CIVILIZED_JUNGLE = [
  "Herd Animal, Large (okapi)",
  "Herd Animal, Med. (duiker)",
  "Herd Animal, Small (duiker)",
  "Herd Animal, V. Large (buffalo)",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Commoner",
  "Man, Commoner",
  "Man, Merchant",
  "Man, Merchant",
  "Man, Patroller (bowmen)",
  "Man, Patroller (bowmen)",
  "Man, Pilgrim",
  "Man, Pilgrim",
  "Man, Tribal Warrior",
  "Man, Tribal Warrior",
  "Man, Tribal Warrior",
  "Man, Tribal Warrior",
  "Neanderthals",
  "Lycan., Weretiger",
].freeze
_CIVILIZED_SWAMP = [
  "Herd animal, Med. (deer)",
  "Herd animal, Med. (deer)",
  "Herd animal, Med. (deer)",
  "Herd animal, V. Large (wisent)",
  "Herd animal, V. Large (wisent)",
  "Herd animal, V. Large (wisent)",
  "Man, Bandit",
  "Man, Bandit",
  "Man, Brigand",
  "Man, Brigand",
  "Man, Merchant",
  "Man, Commoner",
  "Man, Commoner",
  "Man, Commoner",
  "Man, Commoner (fishers)",
  "Man, Commoner (fishers)",
  "Man, Commoner (fishers)",
  "Man, Patroller (bowmen)",
  "Man, Patroller (bowmen)",
  "Lycan., Wererat",
].freeze
CIVILIZED_ENCOUNTERS_BY_TERRAIN = {
  "barrens_rocky" => _CIVILIZED_BARRENS,
  "barrens_tundra" => _CIVILIZED_TIAGA,
  "desert_any" => _CIVILIZED_BARRENS,
  "forest_deciduous" => _CIVILIZED_FOREST,
  "forest_tiaga" => _CIVILIZED_TIAGA,
  "grassland_farmland" => _CIVILIZED_GRASS,
  "grassland_meadow" => _CIVILIZED_GRASS,
  "grassland_savana" => _CIVILIZED_SAVANNA,
  "grassland_steppe" => _CIVILIZED_GRASS,
  "hills_any" => _CIVILIZED_HILLS,
  "jungle_any" => _CIVILIZED_JUNGLE,
  "mountains_forested" => _CIVILIZED_HILLS,
  "mountains_snowy" => _CIVILIZED_HILLS,
  "mountains_volcanic" => _CIVILIZED_HILLS,
  "river_desert" => _CIVILIZED_BARRENS,
  "river_jungle" => _CIVILIZED_SAVANNA,
  "river_other" => _CIVILIZED_GRASS,
  "scrubland_dense" => _CIVILIZED_FOREST,
  "scrubland_sparse" => _CIVILIZED_GRASS,
  "swamp_any" => _CIVILIZED_SWAMP,
}.freeze
# rubocop:enable Naming/VariableName
