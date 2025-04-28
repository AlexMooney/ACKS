# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "pry"
  gem "thor", "~> 1.2.1"
end

WARM_TEMPERATURE_BY_ROLL = {
  1 => "Cold",
  4 => "Chilly",
  5 => "Brisk",
  8 => "Balmy",
  10 => "Warm",
  12 => "Hot",
  19 => "_**Sweltering**_",
}.freeze
COLD_TEMPERATURE_BY_ROLL = {
  -1 => "_**Frigid**_",
  1 => "Very Cold",
  4 => "Quite Cold",
  6 => "Cold",
  8 => "Chilly",
  10 => "Brisk",
  12 => "Balmy",
}.freeze
PRECIPITATION_BY_ROLL = {
  -3 => "_**Sunbaked**_",
  3 => "Clear",
  4 => "Partly Cloudy",
  5 => "Mostly Cloudy",
  6 => "Overcast",
  9 => "_**Drizzly**_",
  19 => "_**Rainy**_",
}.freeze
WIND_BY_ROLL = {
  4 => "Still",
  6 => "Gentle",
  9 => "Moderate",
  11 => "Strong",
  13 => "_**Windy**_",
  19 => "_**Stormy**_",
}.freeze

require_relative "tables"

# Randomly roll weather for 28 days
class Weather < Thor
  include Tables

  desc "weather T_DAY, T_NIGHT, PRECIPITATION, WIND, DAYS=28", "Roll weather for a month"
  def weather(day_modifier, night_modifier, precipitation, wind, days = 28)
    day_modifier = day_modifier.to_i
    night_modifier = night_modifier.to_i
    precipitation = precipitation.to_i
    wind = wind.to_i
    days = days.to_i

    day_table = day_modifier.positive? ? WARM_TEMPERATURE_BY_ROLL : COLD_TEMPERATURE_BY_ROLL
    night_table = night_modifier.positive? ? WARM_TEMPERATURE_BY_ROLL : COLD_TEMPERATURE_BY_ROLL

    puts "| Date | Day | Night | Precipitation | Wind |"
    puts "| ---- | --- | ----- | ------------- | ---- |"
    days.times do |idx|
      day = idx + 1
      temperature_roll = rand(1..6) + rand(1..6)
      day_temperature = roll_table(day_table, temperature_roll + day_modifier)
      night_temperature = roll_table(night_table, temperature_roll + night_modifier)
      precipitation_roll = rand(1..6) + rand(1..6)
      precipitation = roll_table(PRECIPITATION_BY_ROLL, precipitation_roll)
      wind_roll = rand(1..6) + rand(1..6)
      wind = roll_table(WIND_BY_ROLL, wind_roll)
      if drizzling?(precipitation) && freezing?(night_temperature)
        precipitation = "_**Drizzly**_ (Flurry)"
      elsif drizzling?(precipitation) && wind == "Still"
        precipitation = "Misty"
      end

      puts "| #{day} | #{day_temperature} | #{night_temperature} | #{precipitation} | #{wind} |"
    end
  end

  private

  def freezing?(temperature)
    temperature == "Very Cold" || temperature == "Quite Cold" || temperature.include?("Frigid")
  end

  def drizzling?(precipitation)
    precipitation.include?("Drizzly")
  end
end

Weather.start(ARGV)
