# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "pry"
  gem "thor", "~> 1.2.1"
end

require_relative "tables"

class GemsAndArtObjects < Thor
  include Tables

  GEM_VALUE_BY_ROLL = {
    10 => 10,
    25 => 25,
    40 => 50,
    55 => 75,
    70 => 100,
    80 => 250,
    90 => 500,
    95 => 750,
    100 => 1000,
    110 => 1500,
    125 => 2000,
    145 => 4000,
    165 => 6000,
    175 => 8000,
    180 => 10_000,
  }.freeze
  GEM_DESCRIPTIONS_BY_VALUE = {
    10 => %w[azurite hematite malachite obsidian quartz],
    25 => ["agate", "lapis lazuli", "tiger eye", "turquoise"],
    50 => %w[bloodstone crystal citrine jasper moonstone onyx],
    75 => %w[carnelian chalcedony sardonx zircon],
    100 => %w[amber amethyst coral jade jet tourmaline],
    250 => %w[garnet pearl spinel],
    500 => %w[aquamarine alexandrite topaz],
    750 => ["opal", "star ruby", "star sapphire", "sunset amethyst", "imperial topaz"],
    1000 => ["black sapphire", "diamond", "emerald", "jacinth", "ruby"],
    1500 => ["amber with preserved extinct creatures", "whorled nephrite jade", "blue diamond"],
    2000 => ["black pearl", "baroque pearl", "crystal geode"],
    4000 => ["facet cut imperial topaz", "flawless diamond"],
    6000 => ["facet cut star sapphire", "facet cut star ruby"],
    8000 => ["flawless facet cut diamond", "flawless facet cut emerald", "flawless facet cut ruby",
             "flawless facet cut jacinth"],
    10_000 => ["flawless facet cut black sapphire", "flawless facet cut blue diamond"],
  }.freeze
  ART_OBJECT_VALUE_BY_ROLL = {
    10 => "2d20",
    25 => "2d10*10",
    40 => "2d4*100",
    70 => "2d6*100",
    80 => "3d6*100",
    95 => "1d4*1000",
    100 => "2d4*1000",
    125 => "3d4*1000",
    145 => "2d8*1000",
    155 => "3d6*1000",
    165 => "2d20*1000",
    175 => "1d4*10_000",
    180 => "1d8*10_000",
  }.freeze

  ROLL_BY_QUALITY = {
    low: "2d20",
    medium: "1d100",
    high: "80 + 1d100",
  }.freeze
  desc "gems QUALITY QUANTITY=1", "Generates random gems of a given quality"
  def gems(quality, quantity = 1)
    puts "Generating #{quantity} #{quality} gems"
    gems = quantity.to_i.times.map do
      roll = roll_dice(ROLL_BY_QUALITY[quality.to_sym])
      value = roll_table(GEM_VALUE_BY_ROLL, roll)
      description = roll_table(GEM_DESCRIPTIONS_BY_VALUE[value])
      "#{description} #{value}gp"
    end
    gems.tally.each do |description, count|
      if count > 1
        puts "#{count}x #{description}"
      else
        puts description
      end
    end
  end

  desc "objects QUALITY QUANTITY=1", "Generates random art objects of a given quality"
  def objects(quality, quantity = 1)
    puts "Generating #{quantity} #{quality} art objects"
    objects = quantity.to_i.times.map do
      roll = roll_dice(ROLL_BY_QUALITY[quality.to_sym])
      value = roll_dice(roll_table(ART_OBJECT_VALUE_BY_ROLL, roll))
      "#{value}gp art object"
    end
    objects.tally.each do |description, count|
      if count > 1
        puts "#{count}x #{description}"
      else
        puts description
      end
    end
  end
end

GemsAndArtObjects.start(ARGV)
