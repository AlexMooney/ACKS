#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/acks"

class Acks
  include SpellCheck

  def building
    puts Building.construct.description
    # puts
    # puts Building::Townhouse.new(:large, Building::Townhouse).description
    # puts Building::Townhouse.new(:large, Building::Townhouse).description
    # puts Building::Store.new(:large, Building::Store).description
    # puts Building::Workshop.new(:large, Building::Workshop).description
  end

  def magic_item_prompt
    magic_items(**TTY::Prompt.new.collect do
      key(:common).ask("Numebr of Common magic items:", convert: :int)
      key(:uncommon).ask("Number of Uncommon magic items:", convert: :int)
      key(:rare).ask("Number of Rare magic items:", convert: :int)
      key(:very_rare).ask("Number of Very Rare magic items:", convert: :int)
      key(:legendary).ask("Number of Legendary magic items:", convert: :int)
    end)
  end

  def magic_items(common:, uncommon: 0, rare: 0, very_rare: 0, legendary: 0)
    common = common.to_i
    uncommon = uncommon.to_i
    rare = rare.to_i
    very_rare = very_rare.to_i
    legendary = legendary.to_i

    puts TTMagicItems.new(common:, uncommon:, rare:, very_rare:, legendary:)
  end

  def character
    level = TTY::Prompt.new.ask("Character level:", convert: :int, default: 1, min: 1, max: 14)
    class_type = TTY::Prompt.new.select("Character class type:", filter: true, per_page: 15) do |menu|
      menu.choice("Random", nil)
      Character::CLASS_TYPE.each_value do |class_type|
        menu.choice(class_type.capitalize, class_type)
      end
    end
    character_class = nil
    unless class_type.nil?
      character_class = TTY::Prompt.new.select("Character class:", filter: true, per_page: 15) do |menu|
        menu.choice("Random", nil)
        Character::ClassTables::CLASS_BY_TYPE[class_type].values.uniq.each do |klass|
          menu.choice(klass.capitalize, klass)
        end
      end
    end
    ethnicity = TTY::Prompt.new.select("Ethnicity:", filter: true, per_page: 20) do |menu|
      menu.choice("Random", nil)
      Character::Descriptions::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.each_key do |ethnicity|
        menu.choice(ethnicity.capitalize, ethnicity)
      end
    end
    sex = TTY::Prompt.new.select("Sex", filter: true) do |menu|
      menu.choice("Random based on class", nil)
      menu.choice("Male", "male")
      menu.choice("Female", "female")
    end

    puts Character.new(level, class_type:, character_class:, ethnicity:, sex:)
  end

  def merchant_mariners
    puts MerchantMariners.new
  end

  def naval_mariners
    puts NavalMariners.new
  end

  def encounter_prompt
    prompt = TTY::Prompt.new
    listing = prompt.select("Choose a monster listing:", filter: true, per_page: 15) do |menu|
      Dir.glob("lib/monster/listing/*.rb").each do |file|
        class_words = File.basename(file, ".rb").split("_").map(&:capitalize)
        menu.choice(class_words.join(" "), class_words.join)
      end
    end
    location = prompt.select("Dungeon or Wilderness?", %w[dungeon wilderness], filter: true, per_page: 15)
    lair = prompt.select("Is this a lair encounter?", %w[random true false], filter: true, per_page: 15)
    lair = nil if lair == "random"
    encounter(listing, location, lair)
  end

  def encounter(listing, location = "wilderness", lair = nil)
    in_lair = lair && lair != "false" && lair != "0"
    listings = Dir.glob("lib/monster/listing/*.rb").map do |file|
      File.basename(file, ".rb").split("_").map(&:capitalize).join
    end
    listing = spell_check(listing, listings)
    listing_class = Monster::Listing.const_get(listing)

    puts(case location
         when "wilderness"
           listing_class.wilderness_encounter(in_lair:)
         when "dungeon"
           listing_class.dungeon_encounter(in_lair:)
         else
           raise ArgumentError, "Unknown location: #{location}. Use 'wilderness' or 'dungeon'."
         end)
  end

  def nautical_encounters_prompt
    prompt = TTY::Prompt.new
    choices = %w[Civilized Borderlands Outlands Unsettled].each_with_index.to_h
    danger_level = prompt.select("Choose a danger level:", choices, filter: true, convert: :int, per_page: 15)
    danger_level += 1 # Convert to 1-based index; trade route basically subtract 1
    trade_route = prompt.no?("On a trade route?")
    num = prompt.ask("How many encounters to generate?", convert: :int, default: 20)

    nautical_encounters(danger_level, trade_route, num)
  end

  def nautical_encounters(danger_level, trade_route = nil, num = 20)
    puts Encounters::NauticalEncounter.new(danger_level, trade_route:).danger_label
    num.to_i.times do
      puts Encounters::NauticalEncounter.new(danger_level, trade_route:)
    end
  end

  def domain_encounters_prompt
    prompt = TTY::Prompt.new
    choices = %w[Civilized Borderlands Outlands Unsettled].each_with_index.to_h
    danger_level = prompt.select("Choose a danger level:", choices, filter: true, convert: :int, per_page: 15)
    danger_level += 1 # Convert to 1-based index
    terrain = prompt.select("What terrain type is the domain?",
                            Terrain::TERRAIN_TYPES, filter: true, per_page: 15, default: "scrubland_sparse")
    hexes = prompt.ask("How many hexes in the domain?", convert: :int, default: 39)
    days = prompt.ask("How many days to generate?", convert: :int, default: 28)

    domain_encounters(danger_level, terrain, hexes, days)
  end

  def domain_encounters(danger_level, terrain, hexes, days)
    puts Encounters::WildernessEncounters.new(danger_level).domain_encounters(terrain, hexes, days)
  end

  def saesh_encounters_prompt
    prompt = TTY::Prompt.new
    days = prompt.ask("How many days to generate?", convert: :int, default: 28)
    puts "Saesh's Scrublands (3)"
    puts Encounters::WildernessEncounters.new(2).domain_encounters("scrubland_sparse", 3, days)
    puts ""
    puts "Saesh's Swamp (1)"
    puts Encounters::WildernessEncounters.new(2).domain_encounters("swamp_any", 3, days)
    puts ""
    puts "Saesh's Coast (2)"
    puts Encounters::WildernessEncounters.new(2).littoral_domain_encounters(2, days)
    puts ""
    puts "Fort Ardana (1)"
    puts Encounters::WildernessEncounters.new(2).domain_encounters("scrubland_sparse", 1, days)
    puts ""
    puts "Ardana's Coast (1)"
    puts Encounters::WildernessEncounters.new(2).littoral_domain_encounters(1, days)
    puts ""
    puts "Fort Haftvad (1)"
    puts Encounters::WildernessEncounters.new(2).domain_encounters("scrubland_sparse", 1, days)
    puts ""
    puts "Haftvad's Coast (1)"
    puts Encounters::WildernessEncounters.new(2).littoral_domain_encounters(1, days)
  end

  def treasure_prompt
    prompt = TTY::Prompt.new
    treasure_types = prompt.ask("Enter treasure types (e.g., 'R' or 'AAAC'):")
    return if treasure_types.nil? || treasure_types.strip.empty?

    treasure(treasure_types.gsub(/\s+/, "").upcase)
  end

  def treasure(treasure_types)
    treasure_types = treasure_types.upcase
    puts Treasure.new(treasure_types)
  end

  def weather_prompt
    prompt = TTY::Prompt.new
    prompt.say("Weather modifiers are found in JJ page 41.")
    day_modifier = prompt.ask("Day temperature modifier:", convert: :int, default: 0)
    night_modifier = prompt.ask("Night temperature modifier:", convert: :int, default: 0)
    precipitation_modifier = prompt.ask("Precipitation modifier:", convert: :int, default: 0)
    wind_modifier = prompt.ask("Wind modifier:", convert: :int, default: 0)

    weather(day_modifier, night_modifier, precipitation_modifier, wind_modifier)
  end

  def weather(day_modifier, night_modifier, precipitation_modifier, wind_modifier)
    puts Weather.new(day_modifier:, night_modifier:, precipitation_modifier:, wind_modifier:).roll
  end

  def spell_scrolls
    prompt = TTY::Prompt.new
    number = prompt.ask("Enter number of scrolls", convert: :int, default: 1, min: 1)
    return if number.nil?

    levels = prompt.ask("How many spell levels per scroll?", convert: :int, default: 1, min: 1)
    return if levels.nil?

    number.times do
      puts SpellScroll.new(levels).roll_details
    end
  end

  def henchmen
    prompt = TTY::Prompt.new
    market_class = prompt.ask("What market class are you in? (1-6)", convert: :int, default: 1, min: 1, max: 6)
    return if market_class.nil?

    minimum_level = prompt.ask("Minimum level to show? (0)", convert: :int, default: 0, min: 0, max: 4)
    return if minimum_level.nil?

    henchmen = Henchmen.new(market_class:, minimum_level:)
    puts henchmen
  end

  def console
    binding.irb # rubocop:disable Lint/Debugger
  end

  def potion_appearances
    names = ["potion of eagle eyes", "potion of cure light injury", "potion of Giant strength", "potion of delay disease", "potion of simmering rage", "Potion of Ogre Strength", "Potion of arcane armor", "Potion of deathly appearance", "Oil of Excavation", "Potion of Clairaudiency", "Potion of Clairvoyancy", "Potion of Cure Serious Injury", "Potion of Deflect Ordinary Missiles", "Potion of Growth", "Potion of Remove Curse", "potion of discern invisible", "potion of energy invulnerability", "potion of delay disease", "potion of water breathing", "Potion of arcane armor"]
    names.map! { |n| n.split.map(&:capitalize).join(" ").sub(/\s+Of\s+/, " of ") }
    names.sort!
    potions = MagicItems::Potions.new
    names.each { |n| puts "#{n}: #{potions.appearance_by_potion(n)}" }
  end

  def start
    loop do
      puts
      prompt = TTY::Prompt.new
      command = prompt.select("Choose a command:", filter: true, per_page: 15) do |menu|
        menu.choice("xx potion appearances", "potion_appearances")
        menu.choice("Random Treasure", "treasure_prompt")
        menu.choice("Random Magic Items", "magic_item_prompt")
        menu.choice("Random Character", "character")
        menu.choice("Henchmen at Market", "henchmen")
        menu.choice("Detailed Encounter", "encounter_prompt")
        menu.choice("Random Domain Encounters", "domain_encounters_prompt")
        menu.choice("Saesh Domain Encounters", "saesh_encounters_prompt")
        menu.choice("Random Nautical Encounter List", "nautical_encounters_prompt")
        menu.choice("Random Weather", "weather_prompt")
        menu.choice("Merchant Mariners", "merchant_mariners")
        menu.choice("Naval Mariners", "naval_mariners")
        menu.choice("Spell Scrolls", "spell_scrolls")
        menu.choice("Random Building", "building")
        menu.choice("Debug console", "console")
        menu.choice("Quit")
      end
      break if command == "Quit"

      send(command)
    end
  end
end

Acks.new.start if File.basename($PROGRAM_NAME) == "acks.rb"
