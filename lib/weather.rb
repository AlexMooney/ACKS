# frozen_string_literal: true

DAY_TEMPERATURE_BY_ROLL = {
  3 => 'Chilly',
  4 => 'Brisk',
  7 => 'Balmy',
  9 => 'Warm',
  11 => 'Hot',
  12 => '_**Sweltering**_'
}.freeze
NIGHT_TEMPERATURE_BY_ROLL = {
  2 => 'Very Cold',
  4 => 'Quite Cold',
  6 => 'Cold',
  8 => 'Chilly',
  9 => 'Brisk',
  10 => 'Brisk',
  12 => 'Balmy'
}.freeze
PRECIPITATION_BY_ROLL = {
  7 => 'Clear',
  8 => 'Partly Cloudy',
  9 => 'Mostly Cloudy',
  10 => 'Overcast',
  12 => '_**Drizzly**_'
}.freeze
WIND_BY_ROLL = {
  4 => 'Still',
  6 => 'Gentle',
  9 => 'Moderate',
  11 => 'Strong',
  12 => '_**Windy**_'
}.freeze

require_relative 'tables'

# Randomly roll weather for 28 days
class Weather
  include Tables

  def initialize
    puts '| Date | Day | Night | Precipitation | Wind |'
    puts '| ---- | --- | ----- | ------------- | ---- |'
    28.times do |idx|
      day = idx + 1
      temperature_roll = rand(1..6) + rand(1..6)
      day_temperature = roll_table(DAY_TEMPERATURE_BY_ROLL, temperature_roll)
      night_temperature = roll_table(NIGHT_TEMPERATURE_BY_ROLL, temperature_roll)
      precipitation_roll = rand(1..6) + rand(1..6)
      precipitation = roll_table(PRECIPITATION_BY_ROLL, precipitation_roll)
      wind_roll = rand(1..6) + rand(1..6)
      wind = roll_table(WIND_BY_ROLL, wind_roll)
      if drizzling?(precipitation) && freezing?(night_temperature)
        precipitation = '_**Drizzly**_ (Flurry)'
      elsif drizzling?(precipitation) && wind == 'Still'
        precipitation = 'Misty'
      end

      # puts "| #{day} | #{day_temperature} | #{night_temperature} | #{precipitation} | #{wind} |"
      puts "|#{day}(#{night_temperature})/#{precipitation}/#{wind}|"
    end
  end

  private

  def freezing?(temperature)
    temperature == 'Very Cold' || temperature == 'Quite Cold' || temperature.include?('Frigid')
  end

  def drizzling?(precipitation)
    precipitation.include?('Drizzly')
  end
end

Weather.new
