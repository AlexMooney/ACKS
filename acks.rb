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
    end)
  end

  def magic_items(common:, uncommon: 0, rare: 0)
    common = common.to_i
    uncommon = uncommon.to_i
    rare = rare.to_i

    puts TTMagicItems.new(common:, uncommon:, rare:)
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
    puts Character.new(level, class_type:, character_class:, ethnicity:)
  end

  def merchant_mariners
    puts MerchantMariners.new
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

  def treasure_prompt
    prompt = TTY::Prompt.new
    treasure_types = prompt.ask("Enter treasure types (e.g., 'R' or 'AAAC'):")
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
    precipitation = prompt.ask("Precipitation modifier:", convert: :int, default: 0)
    wind = prompt.ask("Wind modifier:", convert: :int, default: 0)

    weather(day_modifier, night_modifier, precipitation, wind)
  end

  def weather(day_modifier, night_modifier, precipitation, wind, prevailing = nil)
    day_modifier = day_modifier.to_i
    night_modifier = night_modifier.to_i
    precipitation = precipitation.to_i
    wind = wind.to_i

    puts Weather.new(day_modifier:, night_modifier:, precipitation:, wind:, prevailing:).roll
  end

  def console
    binding.irb # rubocop:disable Lint/Debugger
  end

  def start
    loop do
      puts
      prompt = TTY::Prompt.new
      command = prompt.select("Choose a command:", filter: true, per_page: 15) do |menu|
        menu.choice("Random Treasure", "treasure_prompt")
        menu.choice("Random Magic Items", "magic_item_prompt")
        menu.choice("Random Character", "character")
        menu.choice("Random Encounter", "encounter_prompt")
        menu.choice("Random Nautical Encounter List", "nautical_encounters_prompt")
        menu.choice("Random Weather", "weather_prompt")
        menu.choice("Merchant Mariners", "merchant_mariners")
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
