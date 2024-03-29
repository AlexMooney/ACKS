# frozen_string_literal: true

Monster = Struct.new('Monster', :floor, :native_level, :name, :num_no_lair, :num_lair, :lair_chance, :treasure_type) do
  attr_accessor :lair, :number_appearing

  def to_s
    "#{number_appearing} #{name} #{lair ? 'lair' : ''} #{treasure}".squeeze(' ').strip
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
    dice_string.sub('*', '').gsub(/\s/, '').split('+').sum do |fragment|
      number, sides = fragment.split('d').map(&:to_i)
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
    num_lair&.end_with?('*')
  end

  def treasure
    "treasure #{treasure_type}" if lair && treasure_type
  end

  def <=>(other)
    if name == other.name
      case [number_appearing.class, other.number_appearing.class]
      when [String, String]
        number_appearing <=> other.number_appearing
      when [String, Integer]
        -1
      when [Integer, String]
        1
      when [Integer, Integer]
        number_appearing <=> other.number_appearing
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
  { 1 => ['Goblin',           '2d4',  '2d6*',  0.4,  'E'],
    2 => ['Kobold',           '4d4',  '1d6*',  0.4,  'E'],
    3 => ['Morlock',          '1d12', '1d8*',  0.35, 'E'],
    4 => ['Orc',              '2d4',  '2d6*',  0.35, 'G'],
    5 => ['Beetle, Luminous', '1d8',  '2d6',   0.4],
    6 => ['Centipede, Giant', '2d4',  '2d12',  0.1],
    7 => ['Ferret, Giant',    '1d8',  '1d12',  0.25, 'A'],
    8 => ['Rat, Giant',       '3d6',  '3d10',  0.1,  'A'],
    9 => ['Men, Brigand',     '2d4',  '1d10*', 0.2,  'H'],
    10 => ['Skeleton',        '3d4',  '3d10',  0.35],
    11 => ['Strix',           '1d10', '3d12',  0.4, 'F'],
    12 => ['NPC Party Lvl 1', '1d4+2', '1*',   0] },
  2 =>
  { 1 => ['Gnoll',                  '1d6', '2d6*', 0.2, 'G'],
    2 => ['Hobgoblin',              '1d6', '1d8*', 0.25, 'E'],
    3 => ['Lizardman',              '2d4', '1d8*', 0.3,  'L'],
    4 => ['Troglydyte',             '1d8', '1d10*', 0.15, 'J'],
    5 => ['Bat, Giant',             '1d10', '1d10', 0.35],
    6 => ['Fly, Giant Carnivorous', '1d8', '2d6', 0.35, 'C'],
    7 => ['Locust, Cavern',         '1d10', '2d10', 0.3],
    8 => ['Snake, Pit Viper',       '1d8'],
    9 => ['Ghoul, Grave',           '1d6', '2d8', 0.2, 'E'],
    10 => ['Men, Berserker',        '1d6', '1d8*', 0.2, 'J'],
    11 => ['Zombie',                '2d4', '4d6', 0.35],
    12 => ['NPC Party Lvl 2',       '1d4+2', '1*', 0] },
  3 =>
  { 1 => ['Bugbear',               '2d4', '1d4*', 0.25, 'L'],
    2 => ['Lycanthrope, Werewolf', '1d6', '2d6', 0.25, 'J'],
    3 => ['Ogre',                  '1d6', '1d3*', 0.2, 'J and special'],
    4 => ['Hobgholl',              '1d6', '1d10', 0.35, 'G'],
    5 => ['Ant, Giant',            '2d4', '4d6', 0.1, 'I and special'],
    6 => ['Lizard, Giant Draco',   '1d3', '1d6', 0.25],
    7 => ['Scorpion, Giant',       '1d6', '1d6', 0.5],
    8 => ['Wolf, Dire',            '1d4', '2d4', 0.1],
    9 => ['Carrion Horror',        '1d3', '1d3', 0.25],
    10 => ['Gargoyle',             '1d6', '2d4', 0.2, 'J'],
    11 => ['Ghoul, Marsh',         '1d10', '2d4*', 0.35, 'N'],
    12 => ['NPC Party Lvl 4',      '1d4+2', '1*', 0] },
  4 =>
  { 1 => ['Lycanthrope, Wereboar',          '1d4', '2d4', 0.2, 'J'],
    2 => ['Lycanthrope, Weretiger',         '1d4', '1d4', 0.15, 'J'],
    3 => ['Minotaur',                       '1d6', '1d8', 0.2, 'L,G'],
    4 => ['Attercop, Monsterous',           '1d3', '1d3', 0.7, 'F'],
    5 => ['Boar, Giant',                    '1d4', '1d4', 0.25],
    6 => ['Owlbeast',                       '1d4', '1d4', 0.3, 'I'],
    7 => ['Acanthaspis, Giant',             '1d6', '1d8', 0.15, 'I'],
    8 => ['Snake, Giant Python',            '1d4', '1d4', 0.2],
    9 => ['Lizard, Giant Horned Chameleon', '1d3', '1d6', 0.25],
    10 => ['Medusa',                        '1d3', '1d4', 0.5, 'H'],
    11 => ['Mass, Gelatinous',              '1', '1', 1.0, 'C,A'],
    12 => ['NPC Party Lvl 5',               '1d4+2', '1*', 0] },
  5 =>
  { 1 => ['Ettin',               '1d2', '1d4', 0.2, 'N,H'],
    2 => ['Giant, Hill',         '1d4', '2d4', 0.25, 'N'],
    3 => ['Giant, Stone',        '1d3', '1d6', 0.25, 'N'],
    4 => ['Troll',               '1d8', '1*', 0.4, 'O'],
    5 => ['Arane',               '1',   '1d3', 0.7, 'J'],
    6 => ['Worm, Great Ice',     '1',   '1d6', 0.25, 'P'],
    7 => ['Basilisk',            '1d6', '1d6', 0.4, 'P'],
    8 => ['Hell Hound, Greater', '2d4', '2d4', 0.3, 'P'],
    9 => ['Salamander, Flame',   '1d4+1', '2d4', 0.25, 'Q'],
    10 => ['Specter',            '1d4', '1d8', 0.2, 'N,N'],
    11 => ['Wyvern',             '1d2', '1d6', 0.3, 'M'],
    12 => ['NPC Party Lvl 8',    '1d4+3', '1*', 0] },
  6 =>
  { 1 => ['Level 6 monster', '1', '1d4', 0.2, 'R'] }
}.freeze

WILDERNESS_MONSTERS = {
  'HillsEnc' =>
  { 1 => '[HillsMen]',
    2 => '[HillsFlyer]',
    3 => '[HillsHumanoid]',
    4 => '[HillsHumanoid]',
    5 => '[HillsAnimal]',
    6 => '[Unusual]',
    7 => '[Dragon]',
    8 => '[HillsFlyer]' },
  'CityMen' =>
  { 1 => 'Cleric',
    2 => 'Cleric',
    3 => 'Fighter',
    4 => 'Fighter',
    5 => 'Mage',
    6 => 'Merchant',
    7 => 'Merchant',
    8 => 'Noble',
    9 => 'NPC Party',
    10 => 'NPC Party',
    11 => 'Thief',
    12 => 'Venturer' },
  'Unusual' =>
  { 1 => 'Basilisk',
    2 => 'Blink Dog',
    3 => 'Centaur',
    4 => 'Gorgon',
    5 => 'Hellhound',
    6 => 'Werewolf',
    7 => 'Medusa',
    8 => 'Phase Tiger',
    9 => 'Rust Monster',
    10 => 'Skittering Maw',
    11 => 'Treant',
    12 => 'White Ape' },
  'ClearHumanoid' => { 1 => '[GrassHumanoid]' },
  'OceanSwimmer' =>
  { 1 => 'Dragon Turtle',
    2 => 'Hydra',
    3 => 'Merman',
    4 => 'Giant Octopus',
    5 => 'True Dragon',
    6 => 'Sea Serpent',
    7 => '[SharkTable]',
    8 => '[SharkTable]',
    9 => 'Skittering Maw',
    10 => 'Sea Snake',
    11 => 'Giant Squid',
    12 => '[WhaleTable]' },
  'RiverMen' =>
  { 1 => 'Brigand',
    2 => 'Bandit',
    3 => 'NPC Party',
    4 => 'Merchant',
    5 => 'Pirate',
    6 => 'Pirate',
    7 => 'Pirate',
    8 => 'Cleric',
    9 => 'Mage',
    10 => 'Fighter',
    11 => 'Merchant',
    12 => 'NPC Party' },
  'BarrenMen' => { 1 => '[MountainMen]' },
  'HillsHumanoid' => { 1 => '[MountainHumanoid]' },
  'OceanFlyer' => { 1 => '[OtherFlyer]' },
  'HillsFlyer' => { 1 => '[OtherFlyer]' },
  'JungleMen' =>
  { 1 => 'Barbarian',
    2 => 'Berserker',
    3 => 'Brigand',
    4 => 'Brigand',
    5 => 'Brigand',
    6 => 'Cleric',
    7 => 'Fighter',
    8 => 'Mage',
    9 => 'NPC Party',
    10 => 'NPC Party',
    11 => 'Thief',
    12 => 'Venturer' },
  'SwampSwimmer' =>
  { 1 => 'Giant Crab',
    2 => 'Crocodile',
    3 => 'Large Crocodile',
    4 => 'Giant Crocodile',
    5 => 'Giant Catfish',
    6 => 'Insect Swarm',
    7 => 'Insect Swarm',
    8 => 'Giant Leech',
    9 => 'Giant Leech',
    10 => 'Lizardman',
    11 => 'Lizardman',
    12 => 'Skittering Maw' },
  'GrassAnimal' =>
  { 1 => 'Antelope',
    2 => 'Boar',
    3 => 'Lion',
    4 => 'Panther',
    5 => 'Elephant',
    6 => '(Giant )%0.33Hawk',
    7 => 'Riding Horse',
    8 => 'Giant Tuatara',
    9 => 'Donkey',
    10 => 'Pit Viper',
    11 => 'Giant Weasel',
    12 => 'Giant Rattlesnake' },
  'CityHumanoid' =>
  { 1 => 'Doppelganger',
    2 => 'Dwarf',
    3 => 'Elf',
    4 => 'Gnome',
    5 => 'Halfling',
    6 => 'Pixie',
    7 => 'Sprite',
    8 => 'Werebear',
    9 => 'Wereboar',
    10 => 'Wererat',
    11 => 'Weretiger',
    12 => 'Werewolf' },
  'OceanMen' => { 2 => 'Buccaneer', 7 => 'Merchant', 8 => 'NPC Party', 12 => 'Pirate' },
  'BarrenAnimal' =>
  { 1 => 'Antelope',
    2 => 'Cave Bear',
    3 => 'Mountain Lion',
    4 => '(Giant )%0.33Eagle',
    5 => 'Wild Goat',
    6 => '(Giant )%0.33Hawk',
    7 => 'Rock Baboon',
    8 => 'Pit Viper',
    9 => 'Giant Rattlesnake',
    10 => 'Giant Crab Spider',
    11 => 'Dire Wolf',
    12 => 'Vulture' },
  'WoodsAnimal' =>
  { 1 => 'Antelope',
    2 => '(Giant )%0.33Bat',
    3 => 'Grizzly Bear',
    4 => 'Boar',
    5 => 'Panther',
    6 => '(Giant )%0.33Hawk',
    7 => '(Giant )%0.33Owl',
    8 => 'Pit Viper',
    9 => 'Giant Black Widow Spider',
    10 => 'Unicorn',
    11 => 'Wolf',
    12 => 'Dire Wolf' },
  'InhabitedFlyer' => { 1 => '[OtherFlyer]' },
  'SwampHumanoid' =>
  { 1 => 'Gnoll',
    2 => 'Goblin',
    3 => 'Hobgoblin',
    4 => 'Lizardman',
    5 => 'Lizardman',
    6 => 'Lizardman',
    7 => 'Naiad',
    8 => 'Ogre',
    9 => 'Orc',
    10 => 'Troglodyte',
    11 => 'Troll',
    12 => 'Troll' },
  'WoodsMen' =>
  { 1 => 'Berserker',
    2 => 'Brigand',
    3 => 'Brigand',
    4 => 'Brigand',
    5 => 'Cleric',
    6 => 'Fighter',
    7 => 'Mage',
    8 => 'Merchant',
    9 => 'NPC Party',
    10 => 'NPC Party',
    11 => 'Thief',
    12 => 'Thief' },
  'DesertHumanoid' =>
  { 1 => 'Bugbear',
    2 => 'Gnoll',
    3 => 'Fire Giant',
    4 => 'Hobgoblin',
    5 => 'Hobgoblin',
    6 => 'Minotaur',
    7 => 'Ogre',
    8 => 'Ogre',
    9 => 'Orc',
    10 => 'Orc',
    11 => 'Troll',
    12 => 'Troll' },
  'HillsMen' => { 1 => '[MountainMen]' },
  'SwampFlyer' => { 1 => '[OtherFlyer]' },
  'HillsAnimal' =>
  { 1 => 'Antelope',
    2 => 'Grizzly Bear',
    3 => 'Boar',
    4 => 'Mountain Lion',
    5 => '(Giant )%0.33Eagle',
    6 => '(Giant )%0.33Hawk',
    7 => 'Riding Horse',
    8 => 'Sheep',
    9 => 'Pit Viper',
    10 => '(Giant )%0.33Owl',
    11 => 'Wolf',
    12 => 'Dire Wolf' },
  'SwampEnc' =>
  { 1 => '[SwampMen]',
    2 => '[SwampFlyer]',
    3 => '[SwampHumanoid]',
    4 => '[Insect]',
    5 => '[SwampSwimmer]',
    6 => '[Undead]',
    7 => '[Undead]',
    8 => '[Dragon]' },
  'GrassMen' =>
  { 1 => 'Berserker',
    2 => 'Brigand',
    3 => 'Cleric',
    4 => 'Fighter',
    5 => 'Mage',
    6 => 'Merchant',
    7 => 'Noble',
    8 => 'Nomad',
    9 => 'NPC Party',
    10 => 'Thief',
    11 => 'Thief',
    12 => 'Venturer' },
  'SettledEnc' =>
  { 1 => '[InhabitedMen]',
    2 => '[InhabitedFlyer]',
    3 => '[InhabitedHumanoid]',
    4 => '[InhabitedMen]',
    5 => '[InhabitedMen]',
    6 => '[Insect]',
    7 => '[InhabitedAnimal]',
    8 => '[Dragon]' },
  'ScrubMen' => { 1 => '[GrassMen]' },
  'ClearAnimal' => { 1 => '[GrassAnimal]' },
  'GrassEnc' =>
  { 1 => '[GrassMen]',
    2 => '[GrassFlyer]',
    3 => '[GrassHumanoid]',
    4 => '[GrassAnimal]',
    5 => '[GrassAnimal]',
    6 => '[Unusual]',
    7 => '[Dragon]',
    8 => '[Insect]' },
  'RocSize' => { 3 => 'Small Roc', 5 => 'Large Roc', 6 => 'Giant Roc' },
  'DesertFlyer' =>
  { 1 => 'Chimera',
    2 => 'Cockatrice',
    3 => 'Gargoyle',
    4 => 'Griffon',
    5 => 'Giant Hawk',
    6 => 'Lammasu',
    7 => 'Manticore',
    8 => 'Pterodactyl',
    9 => 'Small Roc',
    10 => 'Sphinx',
    11 => 'Wyvern',
    12 => 'Vulture' },
  'MountainFlyer' =>
  { 1 => 'Bat Swarm',
    2 => 'Chimera',
    3 => 'Cockatrice',
    4 => 'Gargoyle',
    5 => 'Griffon',
    6 => 'Harpy',
    7 => 'Giant Hawk',
    8 => 'Hippogriff',
    9 => 'Manticore',
    10 => 'Pegasus',
    11 => '[RocSize]',
    12 => 'Wyvern' },
  'RiverEnc' =>
  { 1 => '[RiverMen]',
    2 => '[RiverFlyer]',
    3 => '[RiverHumanoid]',
    4 => '[Insect]',
    5 => '[RiverSwimmer]',
    6 => '[RiverSwimmer]',
    7 => '[RiverAnimal]',
    8 => '[Dragon]' },
  'BarrenEnc' =>
  { 1 => '[BarrenMen]',
    2 => '[BarrenFlyer]',
    3 => '[BarrenHumanoid]',
    4 => '[BarrenHumanoid]',
    5 => '[BarrenAnimal]',
    6 => '[Unusual]',
    7 => '[Dragon]',
    8 => '[Undead]' },
  'CityEnc' => { 1 => '[Undead]', 2 => '[CityHumanoid]', 8 => '[CityMen]' },
  'ScrubAnimal' => { 1 => '[GrassAnimal]' },
  'DesertAnimal' =>
  { 1 => 'Antelope',
    2 => 'Antelope',
    3 => 'Camel',
    4 => 'Camel',
    5 => 'Lion',
    6 => '(Giant )%0.33Hawk',
    7 => 'Giant Gecko',
    8 => 'Giant Tuatara',
    9 => 'Giant Rattlesnake',
    10 => 'Wolf',
    11 => 'Dire Wolf',
    12 => 'Vulture' },
  'JungleHumanoid' =>
  { 1 => 'Bugbear',
    2 => 'Cyclops',
    3 => 'Elf',
    4 => 'Fire Giant',
    5 => 'Hill Giant',
    6 => 'Gnoll',
    7 => 'Goblin',
    8 => 'Lizardman',
    9 => 'Ogre',
    10 => 'Orc',
    11 => 'Troglodyte',
    12 => 'Troll' },
  'WoodsEnc' =>
  { 1 => '[WoodsMen]',
    2 => '[WoodsFlyer]',
    3 => '[WoodsHumanoid]',
    4 => '[Insect]',
    5 => '[Unusual]',
    6 => '[WoodsAnimal]',
    7 => '[WoodsAnimal]',
    8 => '[Dragon]' },
  'BarrenFlyer' =>
  { 1 => 'Cockatrice',
    2 => 'Gargoyle',
    3 => 'Griffon',
    4 => 'Harpy',
    5 => 'Giant Hawk',
    6 => 'Hippogriff',
    7 => 'Lammasu',
    8 => 'Manticore',
    9 => 'Pegasus',
    10 => 'Small Roc',
    11 => 'Stirge',
    12 => 'Wyvern' },
  'DesertEnc' =>
  { 1 => '[DesertMen]',
    2 => '[DesertFlyer]',
    3 => '[DesertHumanoid]',
    4 => '[DesertHumanoid]',
    5 => '[DesertAnimal]',
    6 => '[Unusual]',
    7 => '[Dragon]',
    8 => '[Undead]' },
  'WhaleTable' => { 3 => 'Killer Whale', 5 => 'Narwhal', 6 => 'Sperm Whale' },
  'ScrubFlyer' => { 1 => '[OtherFlyer]' },
  'RiverFlyer' => { 1 => '[OtherFlyer]' },
  'SwampMen' =>
  { 1 => 'Berserker',
    2 => 'Brigand',
    3 => 'Cleric',
    4 => 'Fighter',
    5 => 'Mage',
    6 => 'Merchant',
    7 => 'NPC Party',
    8 => 'NPC Party',
    9 => 'NPC Party',
    10 => 'Thief',
    11 => 'Thief',
    12 => 'Venturer' },
  'RiverHumanoid' =>
  { 1 => 'Bugbear',
    2 => 'Elf',
    3 => 'Gnoll',
    4 => 'Hobgoblin',
    5 => 'Lizardman',
    6 => 'Lizardman',
    7 => 'Naiad',
    8 => 'Naiad',
    9 => 'Ogre',
    10 => 'Orc',
    11 => 'Sprite',
    12 => 'Troll' },
  'InhabitedHumanoid' =>
  { 1 => 'Doppelganger',
    2 => 'Dwarf',
    3 => 'Elf',
    4 => 'Gnome',
    5 => 'Goblin',
    6 => 'Halfling',
    7 => 'Kobold',
    8 => 'Ogre',
    9 => 'Orc',
    10 => 'Pixie',
    11 => 'Sprite',
    12 => 'Wererat' },
  'Undead' =>
  { 1 => 'Ghoul',
    2 => 'Ghoul',
    3 => 'Mummy',
    4 => 'Mummy',
    5 => 'Skeleton',
    6 => 'Skeleton',
    7 => 'Spectre',
    8 => 'Wight',
    9 => 'Wraith',
    10 => 'Vampire',
    11 => 'Zombie',
    12 => 'Zombie' },
  'WoodsHumanoid' =>
  { 1 => 'Bugbear',
    2 => 'Cyclops',
    3 => 'Dryad',
    4 => 'Elf',
    5 => 'Hill Giant',
    6 => 'Gnoll',
    7 => 'Goblin',
    8 => 'Hobgoblin',
    9 => 'Ogre',
    10 => 'Orc',
    11 => 'Pixie',
    12 => 'Troll' },
  'Dragon' =>
  { 1 => 'Basilisk',
    2 => 'Caecilian',
    3 => 'Chimera',
    4 => 'True Dragon',
    5 => 'True Dragon',
    6 => 'Sphinx',
    7 => 'Hydra',
    8 => 'Lamia',
    9 => 'Purple Worm',
    10 => 'Giant Python',
    11 => '[SalamanderTable]',
    12 => 'Wyvern' },
  'MountainMen' =>
  { 1 => 'Barbarian',
    2 => 'Berserker',
    3 => 'Brigand',
    4 => 'Brigand',
    5 => 'Cleric',
    6 => 'Fighter',
    7 => 'Mage',
    8 => 'NPC Party',
    9 => 'NPC Party',
    10 => 'NPC Party',
    11 => 'Thief',
    12 => 'Venturer' },
  'DesertMen' =>
  { 1 => 'Cleric',
    2 => 'Fighter',
    3 => 'Mage',
    4 => 'Merchant',
    5 => 'Noble',
    11 => 'Nomad',
    12 => 'NPC Party' },
  'OceanEnc' =>
  { 1 => '[OceanMen]', 2 => '[OceanFlyer]', 3 => '[Dragon]', 8 => '[OceanSwimmer]' },
  'InhabitedAnimal' =>
  { 1 => 'Antelope',
    2 => 'Boar',
    3 => 'Dog',
    4 => 'Giant Ferret',
    5 => '(Giant )%0.33Hawk',
    6 => 'Riding Horse',
    7 => 'Mule (Donkey)',
    8 => '(Giant )%0.33Rat',
    9 => 'Pit Viper',
    10 => 'Sheep',
    11 => 'Giant Weasel',
    12 => 'Wolf' },
  'MountainHumanoid' =>
  { 1 => 'Dwarf',
    2 => 'Cloud Giant',
    3 => 'Frost Giant',
    4 => 'Hill Giant',
    5 => 'Stone Giant',
    6 => 'Storm Giant',
    7 => 'Goblin',
    8 => 'Kobold',
    9 => 'Ogre',
    10 => 'Orc',
    11 => 'Troglodyte',
    12 => 'Troll' },
  'JungleEnc' =>
  { 1 => '[JungleMen]',
    2 => '[JungleFlyer]',
    3 => '[JungleInsect]',
    4 => '[JungleInsect]',
    5 => '[JungleHumanoid]',
    6 => '[JungleAnimal]',
    7 => '[JungleAnimal]',
    8 => '[Dragon]' },
  'GrassFlyer' => { 1 => '[OtherFlyer]' },
  'Insect' =>
  { 1 => 'Giant Fire Beetle',
    2 => 'Giant Tiger Beetle',
    3 => 'Giant Bombardier Beetle',
    4 => 'Carcass Scavenger',
    5 => 'Giant Centipede',
    6 => 'Giant Ant',
    7 => 'Giant Carnivorous Fly',
    8 => 'Giant Killer Bee',
    9 => 'Giant Rhagodessa',
    10 => 'Giant Scorpion',
    11 => 'Giant Black Widow Spider',
    12 => 'Giant Crab Spider' },
  'ScrubHumanoid' => { 1 => '[GrassHumanoid]' },
  'PrehistoricAnimal' =>
  { 1 => 'Cave Bear',
    2 => 'Sabre-Tooth Tiger',
    3 => 'Giant Crocodile',
    4 => 'Mastodon',
    5 => 'Pteranodon',
    6 => 'Woolly Rhino',
    7 => 'Giant Python',
    8 => 'Stegosaurus',
    9 => 'Titanothere',
    10 => 'Triceratops',
    11 => 'Tyrannosaurus',
    12 => 'Dire Wolf' },
  'ClearFlyer' => { 1 => '[OtherFlyer]' },
  'RiverAnimal' =>
  { 1 => 'Antelope',
    2 => 'Black Bear',
    3 => 'Boar',
    4 => 'Panther',
    5 => 'Giant Crab',
    6 => '(Giant )%0.33Crocodile',
    7 => 'Giant Leech',
    8 => 'Giant Piranha',
    9 => '(Giant )%0.33Rat',
    10 => 'Giant Shrew',
    11 => 'Swan',
    12 => 'Giant Toad' },
  'ClearEnc' =>
  { 1 => '[ClearMen]',
    2 => '[ClearFlyer]',
    3 => '[ClearHumanoid]',
    4 => '[ClearAnimal]',
    5 => '[ClearAnimal]',
    6 => '[Unusual]',
    7 => '[Dragon]',
    8 => '[Insect]' },
  'JungleFlyer' => { 1 => '[OtherFlyer]' },
  'MountainAnimal' =>
  { 1 => 'Antelope',
    2 => 'Cave Bear',
    3 => 'Mountain Lion',
    4 => '(Giant )%0.33Eagle',
    5 => 'Wild Goat',
    6 => '(Giant )%0.33Hawk',
    7 => 'Mule (Donkey)',
    8 => 'Rock Baboon',
    9 => 'Pit Viper',
    10 => 'Giant Rattlesnake',
    11 => 'Wolf',
    12 => 'Dire Wolf' },
  'WoodsFlyer' =>
  { 1 => 'Giant Bat',
    2 => 'Bat Swarm',
    3 => 'Cockatrice',
    4 => 'Griffon',
    5 => 'Giant Hawk',
    6 => 'Hippogriff',
    7 => 'Pegasus',
    8 => 'Giant Owl',
    9 => 'Pixie',
    10 => 'Small Roc',
    11 => 'Sprite',
    12 => 'Stirge' },
  'SharkTable' => { 3 => 'Bull Shark', 5 => 'Mako Shark', 6 => 'Great White Shark' },
  'OtherFlyer' =>
  { 1 => 'Cockatrice',
    2 => 'Giant Carnivorous Fly',
    3 => 'Gargoyle',
    4 => 'Griffon',
    5 => 'Giant Hawk',
    6 => 'Hippogriff',
    7 => 'Giant Killer Bee',
    8 => 'Pegasus',
    9 => 'Pixie',
    10 => 'Small Roc',
    11 => 'Sprite',
    12 => 'Stirge' },
  'SalamanderTable' => { 1 => 'Frost Salamander', 2 => 'Flame Salamander' },
  'MountainEnc' =>
  { 1 => '[MountainMen]',
    2 => '[MountainFlyer]',
    3 => '[MountainHumanoid]',
    4 => '[MountainHumanoid]',
    5 => '[MountainAnimal]',
    6 => '[Unusual]',
    7 => '[Dragon]',
    8 => '[MountainFlyer]' },
  'BarrenHumanoid' =>
  { 1 => 'Bugbear',
    2 => 'Hill Giant',
    3 => 'Goblin',
    4 => 'Gnoll',
    5 => 'Hobgoblin',
    6 => 'Ogre',
    7 => 'Ogre',
    8 => 'Orc',
    9 => 'Orc',
    10 => 'Throghrin',
    11 => 'Troll' },
  'GrassHumanoid' =>
  { 1 => 'Bugbear',
    2 => 'Elf',
    3 => 'Gnoll',
    4 => 'Goblin',
    5 => 'Halfling',
    6 => 'Hobgoblin',
    7 => 'Kobold',
    8 => 'Ogre',
    9 => 'Orc',
    10 => 'Pixie',
    11 => 'Throghrin',
    12 => 'Troll' },
  'ClearMen' => { 1 => '[GrassMen]' },
  'JungleAnimal' =>
  { 1 => 'Antelope',
    2 => 'Boar',
    3 => 'Panther',
    4 => 'Giant Draco Lizard',
    5 => 'Giant Gecko',
    6 => 'Giant Horned Chameleon',
    7 => 'Monkey',
    8 => 'Giant Shrew',
    9 => 'Pit Viper',
    10 => 'Giant Python',
    11 => 'Spitting Cobra',
    12 => 'Giant Crab Spider' },
  'RiverSwimmer' =>
  { 1 => 'Giant Crab',
    2 => 'Crocodile',
    3 => 'Crocodile',
    4 => 'Large Crocodile',
    5 => 'Giant Catfish',
    6 => 'Giant Piranha',
    7 => 'Giant Sturgeon',
    8 => 'Giant Leech',
    9 => 'Lizardman',
    10 => 'Merman',
    11 => 'Naiad',
    12 => 'Skittering Maw' },
  'InhabitedMen' =>
  { 1 => 'Cleric',
    2 => 'Cleric',
    3 => 'Fighter',
    4 => 'Fighter',
    5 => 'Mage',
    6 => 'Merchant',
    7 => 'Noble',
    8 => 'NPC Party',
    9 => 'NPC Party',
    10 => 'Thief',
    11 => 'Thief',
    12 => 'Venturer' },
  'ScrubEnc' =>
  { 1 => '[ScrubMen]',
    2 => '[ScrubFlyer]',
    3 => '[ScrubHumanoid]',
    4 => '[ScrubAnimal]',
    5 => '[ScrubAnimal]',
    6 => '[Unusual]',
    7 => '[Dragon]',
    8 => '[Insect]' }
}.freeze
