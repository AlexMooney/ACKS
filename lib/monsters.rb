# frozen_string_literal: true

Monster = Struct.new("Monster", :floor, :native_level, :name, :num_no_lair, :num_lair, :lair_chance, :treasure_type) do
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
            room.monster = Monster.new(floor, floor.level, "#{name} gang").tap do |m| # more gangs, not bigger gangs
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
  1 => # [Monster name,   no lair #,  lair #, lair chance, treasure type]
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
    12 => ["NPC Party Lvl 1", "1d4+2", "1*",   0], },
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
    12 => ["NPC Party Lvl 2",       "1d4+2", "1*", 0], },
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
    12 => ["NPC Party Lvl 4",      "1d4+2", "1*", 0], },
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
    12 => ["NPC Party Lvl 5",               "1d4+2", "1*", 0], },
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
    12 => ["NPC Party Lvl 8",    "1d4+3", "1*", 0], },
  6 =>
  { 1 => ["Level 6 monster", "1", "1d4", 0.2, "R"] },
}.freeze

CIVILIZED_ENCOUNTERS_BY_TERRAIN = { # rubocop:disable Style/MutableConstant I'll get around to freezing this later
  "barrens" => {
    2 => "Camel",
    3 => "Herd Animal (sheep)",
    4 => "Men, Bandits",
    5 => "Men, Brigands",
    9 => "Men, Commoners",
    11 => "Men, Merchants",
    15 => "Men, Nomads",
    17 => "Men, Patrollers",
    19 => "Men, Pilgrims",
    20 => "Ghoul, Desert",
  },
  "grassland" => {
    1 => "Equine, Medium Horse",
    2 => "Herd Animal (cattle)",
    3 => "Herd Animal (goat)",
    5 => "Herd Animal (sheep)",
    6 => "Men, Bandits",
    7 => "Men, Brigands",
    10 => "Men, Commoners",
    11 => "Men, Commoner shepherds",
    15 => "Men, Merchants",
    17 => "Men, Patrollers",
    19 => "Men, Pilgrims",
    20 => "Lycanthrope, Werewolf",
  },
  "forest" => {
    2 => "Herd Animal (deer)",
    3 => "Herd Animal (elk)",
    5 => "Men, Bandits",
    7 => "Men, Brigands",
    8 => "Men, Berserkers",
    10 => "Men, Commoners",
    11 => "Men, Merchant",
    12 => "Men, Patrollers",
    13 => "Men, Pilgrims",
    17 => "Elf",
    19 => "Gnome",
    20 => "Lycanthrope, Werebear",
  },
  "hills" => {
    1 => "Equine, Donkey",
    2 => "Herd Animal (goat)",
    4 => "Men, Bandits",
    6 => "Men, Brigands",
    7 => "Men, Berserkers",
    8 => "Men, Merchants",
    10 => "Men, Common shepherds",
    11 => "Men, Patrollers",
    12 => "Men, Pilgrims",
    14 => "Gnome",
    16 => "Halfling",
    20 => "Dwarf",
  },
}
CIVILIZED_ENCOUNTERS_BY_TERRAIN["desert"] = CIVILIZED_ENCOUNTERS_BY_TERRAIN["barrens"]
CIVILIZED_ENCOUNTERS_BY_TERRAIN["scrubland"] = CIVILIZED_ENCOUNTERS_BY_TERRAIN["grassland"]
CIVILIZED_ENCOUNTERS_BY_TERRAIN["mountain"] = CIVILIZED_ENCOUNTERS_BY_TERRAIN["hills"]
CIVILIZED_ENCOUNTERS_BY_TERRAIN.freeze

MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY = { # rubocop:disable Style/MutableConstant I'll freeze this later
  "grassland_farmland" => {
    "common" => {
      2 => "Bear, Black",
      3 => "Beastman, Goblin",
      4 => "Beastman, Kobold",
      5 => "Beastman, Orc",
      6 => "Boar, Ordinary",
      7 => "Dog, Hunting",
      8 => "Dog, War",
      9 => "Equine, Donkey",
      10 => "Equine, Light Horse",
      11 => "Equine, Medium Horse",
      12 => "Herd Animal (cattle)",
      13 => "Men, Brigands",
      14 => "Men, Merchants",
      15 => "Raptor, Small",
      16 => "Rhino, Ordinary",
      17 => "Skeleton",
      18 => "Snake, Pit Viper",
      19 => "Swarm, Rat",
      20 => "Zombie",
    },
    "uncommon" => {
      1 => "Ant, Giant",
      2 => "Beastman, Bugbear",
      3 => "Beastman, Gnoll",
      4 => "Beastman, Hobgoblin",
      5 => "Bee, Giant Killer",
      6 => "Beetle, Giant Bombardier",
      7 => "Beetle, Giant Lumi0us",
      8 => "Beetle, Giant Tiger",
      9 => "Boar, Giant",
      10 => "Centipede, Giant",
      11 => "Dragonfly, Giant",
      12 => "Fly, Giant Carnivorous",
      13 => "Ghoul, Grave",
      14 => "Halfling",
      15 => "Lizard, Giant Tuatara",
      16 => "Lycan, Wereboar",
      17 => "Lycan, Wererat",
      18 => "Lycan, Werewolf",
      19 => "Ogre",
      20 => "Raptor, Giant",
      21 => "Roc, Small",
      22 => "Snake, Giant Rattlesnake",
      23 => "Strix",
      24 => "Troll",
      25 => "Varmint, Giant Weasel",
    },
    "rare" => {
      1 => "Blood Hound",
      2 => "Devil Boar",
      3 => "Draugr",
      4 => "Faerie, Brownie",
      5 => "Faerie, Pixiee",
      6 => "Faerie, Spriggan",
      7 => "Gargoyle",
      8 => "Griffon",
      9 => "Lycan, Werebear",
      10 => "Rust Beast",
      11 => "Shadow",
      12 => "Specter",
      13 => "Doppelganger",
      14 => "Hobgholl",
      15 => "Faerie, Sprite",
    },
  },
  "forest_deciduous" => {
    "common" => {
      1 => "Bat, Ordinary",
      2 => "Bear, Grizzy",
      3 => "Beastman, Goblin",
      4 => "Beastman, Orc",
      5 => "Boar, Ordinary",
      6 => "Cat, Panther",
      7 => "Dog, Hunting",
      8 => "Dog, War",
      9 => "Elf",
      10 => "Herd Animal",
      11 => "Hyena, Ordinary",
      12 => "Men, Brigands",
      13 => "Men, Merchants",
      14 => "Raptor, Medium",
      15 => "Raptor, Small",
      16 => "Skeleton",
      17 => "Snake, Pit Viper",
      18 => "Swarm, Bat",
      19 => "Swarm, Rat",
      20 => "Wolf, Ordinary",
      21 => "Zombie",
    },
    "uncommon" => {
      1 => "Acanthaspis, Giant",
      2 => "Ant, Giant",
      3 => "Bat, Giant",
      4 => "Beastman, Bugbear",
      5 => "Beastman, Gnoll",
      6 => "Beastman, Hobgoblin",
      7 => "Beetle, Giant Bombardier",
      8 => "Beetle, Giant Luminous",
      9 => "Beetle, Giant Tiger",
      10 => "Boar, Giant",
      11 => "Centipede, Giant",
      12 => "Dragonfly, Giant",
      13 => "Frog, Giant",
      14 => "Ghoul, Grave",
      15 => "Ghoul, Marsh",
      16 => "Giant, Hill",
      17 => "Hoarflesh",
      18 => "Hyena, Giant",
      19 => "Lycan, Wereboar",
      20 => "Lycan, Wererat",
      21 => "Lycan, Werewolf",
      22 => "Ogre",
      23 => "Owlbeast",
      24 => "Raptor, Giant",
      25 => "Roc, Small",
      26 => "Scorpion, Giant",
      27 => "Spider, Giant Black Widow",
      28 => "Spider, Giant Tarantula",
      29 => "Strix",
      30 => "Stymph",
      31 => "Tick, Giant",
      32 => "Troll",
      33 => "Wasp, Giant",
      34 => "Wolf, Dire",
    },
    "rare" => {
      1 => "Arane",
      2 => "Attercop, Foul",
      3 => "Attercop, Hideous",
      4 => "Attercop, Monstrous",
      5 => "Barghest, Lesser",
      6 => "Bat, Giant Vampire",
      7 => "Blood Hound",
      8 => "Centaur",
      9 => "Cyclops",
      10 => "Dakhanavar, Lesser",
      11 => "Devil Boar",
      12 => "Dragon",
      13 => "Draugr",
      14 => "Faerie, Piskie",
      15 => "Faerie, Pixiee",
      16 => "Faerie, Spriggan",
      17 => "Faerie, Sprite",
      18 => "Gargoyle",
      19 => "Griffon",
      20 => "Hag",
      21 => "Hippogriff",
      22 => "Lycan, Werebear",
      23 => "Lycan, Weretiger",
      24 => "Nymph, Dryad",
      25 => "Rust Beast",
      26 => "Shadow",
      27 => "Skeletal Slayer",
      28 => "Snake, Giant Constricting Viper",
      29 => "Specter",
      30 => "Treeherder",
      31 => "Vampire",
      32 => "Wolf, Warg",
      33 => "Yali",
    },
    "very_rare" => {
      1 => "Barghest, Greater",
      2 => "Bronze Bull",
      3 => "Dakhanavar, Greater",
      4 => "Doppelganger",
      5 => "Faerie, Redcap",
      6 => "Galdrtré",
      7 => "Hell Hawk",
      8 => "Hydra",
      9 => "Medusa",
      10 => "Salamander, Frost",
      11 => "Slug, Giant",
      12 => "Spell Tyrant",
      13 => "Unicorn",
      14 => "Barghest, Greater",
      15 => "Bronze Bull",
    },
  },
}
MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY["grassland_farmland"]["very_rare"] =
  MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY["grassland_farmland"]["rare"]
MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY["grassland"] =
  MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY["grassland_farmland"]

MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY["forest"] =
  MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY["forest_deciduous"]

MONSTER_ENCOUNTERS_BY_TERRAIN_SUBTYPE_AND_RARITY.freeze
