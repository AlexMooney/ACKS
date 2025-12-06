# frozen_string_literal: true

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
  -2 => "_**Sunbaked**_",
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
  11 => "_**Strong**_",
  13 => "_**Very Strong**_",
  19 => "_**Gale**_",
}.freeze
WIND_DIRECTION_BY_ROLL = {
  1 => "Northerly",
  2 => "Northeasterly",
  3 => "Easterly",
  4 => "Southeasterly",
  5 => "Southerly",
  6 => "Southwesterly",
  7 => "Westerly",
  8 => "Northwesterly",
  12 => "Prevailing",
}.freeze
NEXT_WIND_BONUS_BY_WIND = {
  4 => -2,
  6 => -1,
  9 => 0,
  11 => 1,
  13 => 2,
  19 => 4,
}.freeze

require_relative "tables"

class Weather
  include Tables

  attr_reader :day_modifier, :night_modifier, :precipitation_modifier, :wind_modifier, :prevailing

  def initialize(day_modifier:, night_modifier:, precipitation_modifier:, wind_modifier:, prevailing: nil)
    @day_modifier = day_modifier
    @night_modifier = night_modifier
    @precipitation_modifier = precipitation_modifier
    @wind_modifier = wind_modifier
    @prevailing = prevailing
    @next_wind_bonus = 0
    @prior_temperature_roll = 7
    @prior_precipitation_roll = 7
  end

  def roll
    day_table = day_modifier.positive? ? WARM_TEMPERATURE_BY_ROLL : COLD_TEMPERATURE_BY_ROLL
    night_table = night_modifier.positive? ? WARM_TEMPERATURE_BY_ROLL : COLD_TEMPERATURE_BY_ROLL

    labels = ["Date", "Day", "Night", "Precipitation", "Day Wind", "Night Wind"]
    [35, 28, 28].map do |days|
      data = []
      days.times do |idx|
        date = idx + 1
        temperature_roll = rand(1..6) + rand(1..6)
        if temperature_roll > @prior_temperature_roll
          temperature_roll += 1 unless temperature_roll == 12
        elsif temperature_roll < @prior_temperature_roll
          temperature_roll -= 1 unless temperature_roll == 2
        end
        @prior_temperature_roll = temperature_roll
        day_temperature = roll_table(day_table, temperature_roll + day_modifier)
        night_temperature = roll_table(night_table, temperature_roll + night_modifier)

        precipitation_roll = rand(1..6) + rand(1..6)
        if precipitation_roll > @prior_precipitation_roll
          precipitation_roll += 1 unless precipitation_roll == 12
        elsif precipitation_roll < @prior_precipitation_roll
          precipitation_roll -= 1 unless precipitation_roll == 2
        end
        @prior_precipitation_roll = precipitation_roll
        precipitation = roll_table(PRECIPITATION_BY_ROLL, precipitation_roll + precipitation_modifier)
        day_wind = roll_wind
        night_wind = roll_wind

        if drizzling?(precipitation) && freezing?(night_temperature)
          precipitation = "_**Drizzly**_ (Flurry)"
        elsif drizzling?(precipitation) && day_wind == "Still" && night_wind == "Still"
          precipitation = "Misty"
        elsif drizzling?(precipitation) && day_wind == "Still"
          precipitation = "Misty / #{precipitation}"
        elsif drizzling?(precipitation) && night_wind == "Still"
          precipitation = "#{precipitation} / Misty"
        end

        data << [date, day_temperature, night_temperature, precipitation, day_wind, night_wind]
      end
      table = TTY::Table.new(labels, data, width: 100)
      table.render_with MarkdownBorder
    end.join("\n\n")
  end

  private

  def freezing?(temperature)
    temperature == "Very Cold" || temperature == "Quite Cold" || temperature.include?("Frigid")
  end

  def drizzling?(precipitation)
    precipitation.include?("Drizzly")
  end

  def roll_wind
    wind_roll = rand(1..6) + rand(1..6) + @next_wind_bonus + wind_modifier
    @next_wind_bonus = roll_table(NEXT_WIND_BONUS_BY_WIND, wind_roll)
    wind = roll_table(WIND_BY_ROLL, wind_roll)
    wind_direction = roll_table(WIND_DIRECTION_BY_ROLL)
    wind_direction = prevailing if wind_direction == "Prevailing" && prevailing
    wind = "#{wind} #{wind_direction}" unless wind == "Still"
    wind
  end
end
