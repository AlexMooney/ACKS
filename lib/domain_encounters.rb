#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'pry'
  gem 'thor', '~> 1.2.1'
end

require_relative './monsters'

class DomainEncounters < Thor
  desc 'wilderness TERRAIN HEXES', 'Roll encounters one per day for 28 days.'

  DANGER_BY_TERRAIN = {
    'city' => 1,
    'grass' => 1,
    'clear' => 1,
    'scrub' => 1,
    'settled' => 1,
    'river' => 1,
    'aerial' => 2,
    'hills' => 2,
    'woods' => 2,
    'barren' => 3,
    'desert' => 3,
    'jungle' => 3,
    'mountain' => 3,
    'swamp' => 3
  }.freeze

  def wilderness(terrain, hexes)
    terrain = terrain.downcase
    hexes = hexes.to_i

    chance_per_hex = DANGER_BY_TERRAIN[terrain]
    base_encounter_chance = (1.0 - chance_per_hex / 100.0)
    chance_of_encounter = 1.0 - base_encounter_chance**hexes
    puts "Chance of encounter per day is #{(100 * chance_of_encounter).round(1)}%"

    puts '| Day | Creature | Lingering | Lair Group | Domain Recon | Monster Recon | Attitude |'
    puts '| --- | -------- | --------- | ---------- | ------------ | ------------- | -------- |'
    28.times do |i|
      hexes.times do |_h|
        next unless rand >= base_encounter_chance

        creature = choose_creature(terrain)
        lingering = rand(1..100)
        lair = rand(1..100)

        puts "| #{i + 1} | #{creature} | #{lingering} | #{lair} | #{recon_roll} | #{recon_roll} | #{reaction} |"
      end
    end
  end

  private

  def choose_creature(terrain)
    table = MONSTERS["#{terrain.capitalize}Enc"]
    result = roll_table(table)
    while result.start_with?('[')
      binding.pry if MONSTERS[result[1..-2]].nil?
      result = roll_table(MONSTERS[result[1..-2]])
    end
    result
  end

  def roll_table(table)
    roll = rand(1..(table.keys.max))
    roll += 1 while table[roll].nil?
    table[roll]
  end

  def recon_roll
    rand(1..6) + rand(1..6)
  end

  def reaction
    roll = rand(1..6) + rand(1..6)
    case roll
    when 2 then 'Hostile'
    when 3..5 then 'Unfriendly'
    when 6..8 then 'Neutral'
    when 9..11 then 'Indifferent'
    when 12 then 'Friendly'
    end
  end
end

DomainEncounters.start(ARGV)
