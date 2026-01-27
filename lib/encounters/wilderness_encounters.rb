# frozen_string_literal: true

module Encounters
  class WildernessEncounters < RandomEncounter
    DANGER_LEVELS = [
      "Civilized + Road",
      "Civilized or Borderlands + Road",
      "Borderlands or Outlands + Road",
      "Outlands or Unsettled + Road",
      "Unsettled",
    ].freeze
    ENCOUNTER_TYPE_BY_DANGER_LEVEL = {
      0 => {
        11 => "No Encounter",
        20 => "Civilized Encounter",
      },
      1 => {
        10 => "No Encounter",
        17 => "Civilized Encounter",
        18 => "Monster Encounter",
        19 => "Dangerous Terrain Encounter",
        20 => "Valuable Terrain Encounter",
      },
      2 => {
        8 => "No Encounter",
        13 => "Civilized Encounter",
        15 => "Monster Encounter",
        17 => "Dangerous Terrain Encounter",
        19 => "Valuable Terrain Encounter",
        20 => "Unique Terrain Encounter",
      },
      3 => {
        8 => "No Encounter",
        11 => "Civilized Encounter",
        15 => "Monster Encounter",
        17 => "Dangerous Terrain Encounter",
        19 => "Valuable Terrain Encounter",
        20 => "Unique Terrain Encounter",
      },
      4 => {
        6 => "No Encounter",
        12 => "Monster Encounter",
        15 => "Dangerous Terrain Encounter",
        18 => "Valuable Terrain Encounter",
        20 => "Unique Terrain Encounter",
      },
    }.freeze
    DANGEROUS_TERRAIN_ENCOUNTERS = {
      1 => "Awful Despoiling",
      2 => "Challenge",
      3 => "Enshrouding Terrain",
      4 => "Foul Fountain",
      5 => "Hazard",
      6 => "Plague",
      7 => "Poison",
      8 => "Rough Going",
      9 => "Spoilage",
      10 => "Trap",
      11 => "Wasteland",
      12 => "Double",
    }.freeze
    VALUABLE_TERRAIN_ENCOUNTERS = {
      1 => "Cache",
      2 => "Food",
      3 => "Fountain",
      4 => "Hidden Settlement",
      5 => "Monster Carcass",
      6 => "Ore",
      7 => "Ruin",
      8 => "Safe Haven",
      9 => "Shortcut",
      10 => "Useful Herbs",
      11 => "Vista",
      12 => "Double",
    }.freeze
    UNIQUE_TERRAIN_ENCOUNTERS = {
      1 => "Complex Map",
      2 => "Curse",
      3 => "Empowering Place",
      4 => "Lesser Terrain",
      5 => "Magical Place",
      6 => "Magical Resource",
      7 => "Monstrous Shadow",
      8 => "Place of Power",
      9 => "Portal",
      10 => "Relic",
      11 => "Truly Unique",
      12 => "Double",
    }.freeze
    MONSTER_RARITY_BY_DANGER_LEVEL = {
      1 => {
        14 => "common",
        19 => "uncommon",
        20 => "rare",
      },
      2 => {
        12 => "common",
        18 => "uncommon",
        20 => "rare",
      },
      3 => {
        10 => "common",
        15 => "uncommon",
        19 => "rare",
        20 => "very_rare",
      },
      4 => {
        8 => "common",
        14 => "uncommon",
        18 => "rare",
        20 => "very_rare",
      },
    }.freeze

    def wilderness_encounters(terrain)
      terrain_name = terrain
      terrain = Terrain.new(terrain_name)
      20.times do |i|
        roll = rand(1..20)
        danger_label = ""
        current_danger_level = danger_level
        while roll == 1 && current_danger_level < 4
          danger_label += "+"
          current_danger_level += 1
          roll = rand(1..20)
        end
        result = roll_table(ENCOUNTER_TYPE_BY_DANGER_LEVEL[current_danger_level], roll)
        result = case result
                 when /\ADangerous Terrain Encounter\z/
                   "#{result}: #{roll_table(DANGEROUS_TERRAIN_ENCOUNTERS, rand(1..12))}"
                 when /\AValuable Terrain Encounter\z/
                   "#{result}: #{roll_table(VALUABLE_TERRAIN_ENCOUNTERS, rand(1..12))}"
                 when /\AUnique Terrain Encounter\z/
                   "#{result}: #{roll_table(UNIQUE_TERRAIN_ENCOUNTERS, rand(1..12))}"
                 when /\ACivilized Encounter\z/
                   "#{result}: #{civilized_encounter(terrain_name)}"
                 when /\AMonster Encounter\z/
                   rarity = roll_rarity(current_danger_level)
                   "#{result} (#{rarity}): #{monster_encounter(terrain, rarity)}"
                 else
                   result
                 end
        result += " (danger #{danger_label})" unless danger_label.empty?

        puts "- [ ] #{i + 1}: #{result}"
      end
    end

    ENCOUNTER_CHANCE_BY_DANGER_LEVEL = {
      1 => 0.005, # Civilized
      2 => 0.01,  # Borderlands
      3 => 0.03,  # Outlands
      4 => 0.04,  # Unsettled
    }.freeze
    def domain_encounters(terrain, hexes, days = 28)
      terrain_name = terrain.sub("_", ", ")
      terrain = Terrain.new(terrain)
      hexes = hexes.to_i

      chance_per_hex = ENCOUNTER_CHANCE_BY_DANGER_LEVEL[danger_level]
      no_encounter_in_hex = 1.0 - chance_per_hex
      chance_of_encounter = 1.0 - (no_encounter_in_hex**hexes)
      puts "#{DANGER_LEVELS[danger_level].split.first} #{terrain_name} with #{hexes} hexes."
      puts "Chance of encounter per day is #{(100 * chance_of_encounter).round(1)}%.  Rolling #{days} days."
      puts "" # Obsidian requires a newline before tables

      labels = ["Day", "Creature", "Lingering", "Lair Group", "Domain Recon", "Monster Recon", "Attitude"]
      data = []
      days.to_i.times do |i|
        hexes.times do |_h|
          next unless rand >= no_encounter_in_hex

          rarity = roll_rarity(danger_level)
          creature = monster_encounter(terrain, rarity)
          lingering = rand(1..100)
          lair = rand(1..100)

          data << [i + 1, "#{creature} (#{rarity})", lingering, lair, recon_roll, recon_roll, domain_reaction]
        end
      end
      table = TTY::Table.new(labels, data)
      table.render_with MarkdownBorder
    end

    # Water hexes generate Nautical Encounters but at the frequency of domain encounters
    def littoral_domain_encounters(hexes, days = 28)
      chance_per_hex = ENCOUNTER_CHANCE_BY_DANGER_LEVEL[danger_level]
      no_encounter_in_hex = 1.0 - chance_per_hex
      chance_of_encounter = 1.0 - (no_encounter_in_hex**hexes)
      puts "#{DANGER_LEVELS[danger_level].split.first} Littoral with #{hexes} hexes."
      puts "Chance of encounter per day is #{(100 * chance_of_encounter).round(1)}%.  Rolling #{days} days."
      puts "" # Obsidian requires a newline before tables

      labels = ["Day", "Creature", "Lingering", "Lair Group", "Domain Recon", "Monster Recon", "Attitude"]
      data = []
      days.to_i.times do |i|
        hexes.times do |_h|
          next unless rand >= no_encounter_in_hex

          lingering = rand(1..100)
          lair = rand(1..100)
          encounter = Encounters::NauticalEncounter.new(danger_level).to_s
          while encounter.match?(/No Encounter/)
            encounter = Encounters::NauticalEncounter.new(danger_level).to_s
          end

          data << [i + 1, Encounters::NauticalEncounter.new(danger_level).to_s, lingering, lair, recon_roll, recon_roll, domain_reaction]
        end
      end
      table = TTY::Table.new(labels, data)
      table.render_with MarkdownBorder
    end

    private

    def civilized_encounter(terrain_name)
      roll_table(CIVILIZED_ENCOUNTERS_BY_TERRAIN[terrain_name])
    end

    def roll_rarity(danger_level)
      roll_table(MONSTER_RARITY_BY_DANGER_LEVEL[danger_level])
    end

    def monster_encounter(terrain, rarity)
      terrain.random_monster(rarity)
    end

    def recon_roll
      rand(1..6) + rand(1..6)
    end

    def domain_reaction
      roll = rand(1..6) + rand(1..6)
      label = case roll
              when 2 then "Hostile, pillage"
              when 3..5 then "Unfriendly, opportunistic"
              when 6..8 then "Neutral, exploratory"
              when 9..11 then "Mercantilist, trade"
              when 12 then "Friendly, help"
              end
      "#{label} (#{roll})"
    end
  end
end
