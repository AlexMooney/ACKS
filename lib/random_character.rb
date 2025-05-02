#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "pry"
  gem "thor", "~> 1.2.1"
end

require_relative "descriptions"
require_relative "tables"
require_relative "names/tirenean_names"
require_relative "names/celdorean_names"
require_relative "names/kemeshi_names"
require_relative "names/zaharan_names"
require_relative "npc_tables"

class RandomCharacter < Thor
  include Tables

  desc "dwarf STR_BONUS SEX", "Generate a random dwarf character"
  def dwarf(str_bonus, sex = "m")
    build_roll = roll_dice("2d6 + #{2 * str_bonus.to_i}")
    build = roll_table(DWARF_BUILD, build_roll)

    base_height = male?(sex) ? 43 : 41
    height_roll = roll_dice("2d4")
    height = ((base_height + height_roll) * BUILD_HEIGHT_MODIFIER[build]).round
    height_string = "#{height / 12} feet #{height % 12} inches"

    base_weight = male?(sex) ? 130 : 110
    weight_roll = roll_dice("4d10")
    weight = ((base_weight + weight_roll) * BUILD_WEIGHT_MODIFIER[build]).round
    weight_string = "#{weight} pounds"

    eye_color = roll_table(DWARF_EYE_COLOR)
    skin_color = roll_table(DWARF_SKIN_COLOR)
    hair_color = roll_table(DWARF_HAIR_COLOR)
    hair_texture = roll_table(DWARF_HAIR_TEXTURE)
    sex = male?(sex) ? "Male" : "Female"

    puts "Sex: #{sex}, Build: #{build}, Height: #{height_string}, Weight: #{weight_string}, Eyes: #{eye_color}, " \
         "Skin Color: #{skin_color}, Hair: #{hair_texture} #{hair_color}"
  end

  desc "human ETHNICITY STR_BONUS SEX", "Generate a random human character"
  def human(ethnicity, str_bonus, sex = "m")
    build_roll = roll_dice("2d6 + #{2 * str_bonus.to_i}")
    build = roll_table(HUMAN_BUILD, build_roll)

    height_mod, weight_mod = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.fetch(ethnicity) do |missing_key|
      keys = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys
      spell_check = DidYouMean::SpellChecker.new(dictionary: keys).correct(missing_key)
      if spell_check.any?
        puts "Assuming you meant `#{spell_check.first}`."
        ethnicity = spell_check.first
        HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.fetch(ethnicity)
      else
        puts "Didn't find ethnicity `#{missing_key}`.  Valid choices: `#{keys.join '`, `'}`."
        exit
      end
    end

    base_height = male?(sex) ? 60 : 55
    height_roll = roll_dice("2d6")
    height = ((base_height + height_roll + height_mod) * BUILD_HEIGHT_MODIFIER[build]).round
    height_string = "#{height / 12} feet #{height % 12} inches"

    base_weight = male?(sex) ? 110 : 90
    weight_roll = roll_dice("8d6")
    weight = ((base_weight + weight_roll) * BUILD_WEIGHT_MODIFIER[build] * weight_mod).round
    weight_string = "#{weight} pounds"

    eye_color = roll_table(HUMAN_EYE_COLOR_BY_ETHNICITY[ethnicity])
    skin_color = roll_table(HUMAN_SKIN_COLOR_BY_ETHNICITY[ethnicity])
    hair_color = roll_table(HUMAN_HAIR_COLOR_BY_ETHNICITY[ethnicity])
    hair_texture = roll_table(HUMAN_HAIR_TEXTURE_BY_ETHNICITY[ethnicity])
    sex = male?(sex) ? "Male" : "Female"

    puts "Sex: #{sex}, Build: #{build}, Height: #{height_string}, Weight: #{weight_string}, Eyes: #{eye_color}, " \
         "Skin Color: #{skin_color}, Hair: #{hair_texture} #{hair_color}"
  end

  desc "names SEX ETHNICITY", "Generate 10 random names"
  def names(sex = "m", ethnicity = "tirenean")
    method = :"#{ethnicity}_name"
    sex = male?(sex) ? "male" : "female"

    puts "#{sex.capitalize} #{ethnicity.capitalize} names:"
    10.times do
      puts "- [ ] [[#{send(method, sex)}]]"
    end
  end

  desc "character [CLASS_TYPE]", "Generate a random character, optionally picking a class type"
  def character(klass_type = nil)
    ethnicity = random_ethnicity
    klass_type ||= roll_table(CLASS_TYPE)
    klass = roll_table(CLASS_BY_TYPE[klass_type])
    alignment = roll_table(ALIGNMENT)
    level = roll_table(BASE_LEVEL)
    sex = %w[male female].sample
    name = send("#{ethnicity}_name", sex)
    stats = Stats.new(STAT_PREFERENCE_BY_CLASS_TYPE[klass_type])

    puts "#{name} the #{alignment} #{sex} #{klass} of level #{level}"
    puts(Stats::STATS.map do |stat|
      "#{stat}: #{stats.send(stat.downcase)}"
    end.join(", "))
  end

  GENERAL_PROFICIENCIES = [
    "Alchemy", "Animal", "Husbandry", "Animal Training", "Art", "Bargaining", "Caving", "Collegiate Wizardry", "Craft",
    "Diplomacy", "Disguise", "Driving", "Endurance", "Engineering", "Folkways", "Gambling", "Healing", "Intimidation",
    "Knowledge", "Labor", "Language", "Leadership", "Lip Reading", "Manual of Arms", "Mapping", "Military Strategy",
    "Mimicry", "Mountaineering", "Naturalism", "Navigation", "Performance", "Profession", "Revelry", "Riding",
    "Seafaring", "Seduction", "Siege Engineering", "Signaling", "Streetwise", "Survival", "Swimming", "Theology",
    "Tracking", "Trapping"
  ].freeze
  desc "gen_prof", "Pick a random general proficiency"
  def gen_prof
    puts GENERAL_PROFICIENCIES.sample
  end

  private

  def male?(sex_string)
    sex_string.downcase.start_with? "m"
  end

  def random_ethnicity
    "tirenean" # TODO: Randomize
  end
end

RandomCharacter.start(ARGV)
