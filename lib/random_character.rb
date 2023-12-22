#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'pry'
  gem 'thor', '~> 1.2.1'
end

require_relative './descriptions'
require_relative './tables'
require_relative 'names/tirenean_male_given'
require_relative 'names/tirenean_female_given'
require_relative 'names/tirenean_surnames'

class RandomCharacter < Thor
  include Tables

  desc 'dwarf STR_BONUS SEX', 'Generate a random dwarf character'
  def dwarf(str_bonus, sex = 'm')
    build_roll = roll_dice("2d6 + #{2 * str_bonus.to_i}")
    build = roll_table(DWARF_BUILD, build_roll)

    base_height = male?(sex) ? 43 : 41
    height_roll = roll_dice('2d4')
    height = ((base_height + height_roll) * BUILD_HEIGHT_MODIFIER[build]).round
    height_string = "#{height / 12} feet #{height % 12} inches"

    base_weight = male?(sex) ? 130 : 110
    weight_roll = roll_dice('4d10')
    weight = ((base_weight + weight_roll) * BUILD_WEIGHT_MODIFIER[build]).round
    weight_string = "#{weight} pounds"

    eye_color = roll_table(DWARF_EYE_COLOR)
    skin_color = roll_table(DWARF_SKIN_COLOR)
    hair_color = roll_table(DWARF_HAIR_COLOR)
    hair_texture = roll_table(DWARF_HAIR_TEXTURE)
    sex = male?(sex) ? 'Male' : 'Female'

    puts "Sex: #{sex}, Build: #{build}, Height: #{height_string}, Weight: #{weight_string}, Eyes: #{eye_color}, " \
      "Skin Color: #{skin_color}, Hair: #{hair_texture} #{hair_color}"
  end

  desc 'name SEX ETHNICITY', 'Generate 10 random names'
  def name(sex = 'm', ethnicity = 'tirenean')
    sex = male?(sex) ? 'male' : 'female'
    given_name_table = Object.const_get("#{ethnicity}_#{sex}_GIVEN".upcase)
    surname_table = Object.const_get("#{ethnicity}_SURNAMES".upcase)

    puts "#{sex.capitalize} #{ethnicity.capitalize} names:"
    10.times do
      puts "#{roll_table(given_name_table)} #{roll_table(surname_table)}"
    end
  end

  private

  def male?(sex_string)
    sex_string.downcase.start_with? 'm'
  end
end

RandomCharacter.start(ARGV)
