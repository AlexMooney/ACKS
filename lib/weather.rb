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
  11 => "Strong",
  13 => "_**Windy**_",
  19 => "_**Stormy**_",
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

require_relative "tables"

class Weather
  include Tables

  attr_reader :day_modifier, :night_modifier, :precipitation, :wind, :prevailing

  def initialize(day_modifier:, night_modifier:, precipitation:, wind:, prevailing: nil)
    @day_modifier = day_modifier
    @night_modifier = night_modifier
    @precipitation = precipitation
    @wind = wind
    @prevailing = prevailing
  end

  def roll
    day_table = day_modifier.positive? ? WARM_TEMPERATURE_BY_ROLL : COLD_TEMPERATURE_BY_ROLL
    night_table = night_modifier.positive? ? WARM_TEMPERATURE_BY_ROLL : COLD_TEMPERATURE_BY_ROLL

    labels = %w[Date Day Night Precipitation Wind]
    [35, 28, 28].map do |days|
      data = []
      days.times do |idx|
        date = idx + 1
        temperature_roll = rand(1..6) + rand(1..6)
        day_temperature = roll_table(day_table, temperature_roll + day_modifier)
        night_temperature = roll_table(night_table, temperature_roll + night_modifier)
        precipitation_roll = rand(1..6) + rand(1..6)
        precipitation = roll_table(PRECIPITATION_BY_ROLL, precipitation_roll)
        wind_roll = rand(1..6) + rand(1..6)
        wind = roll_table(WIND_BY_ROLL, wind_roll)
        wind_direction = roll_table(WIND_DIRECTION_BY_ROLL)
        wind_direction = prevailing if wind_direction == "Prevailing" && prevailing
        wind = "#{wind} #{wind_direction}" unless wind == "Still"

        if drizzling?(precipitation) && freezing?(night_temperature)
          precipitation = "_**Drizzly**_ (Flurry)"
        elsif drizzling?(precipitation) && wind == "Still"
          precipitation = "Misty"
        end

        data << [date, day_temperature, night_temperature, precipitation, wind]
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
end
