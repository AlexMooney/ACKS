#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/acks"

class Acks < Thor
  desc "building", "Generate a building"
  def building
    puts Building.construct.description
    # puts
    # puts Building::Townhouse.new(:large, Building::Townhouse).description
    # puts Building::Townhouse.new(:large, Building::Townhouse).description
    # puts Building::Store.new(:large, Building::Store).description
    # puts Building::Workshop.new(:large, Building::Workshop).description
  end

  desc "magic_items COMMON UNCOMMMON=0 RARE=0", "Generate magic items"
  def magic_items(common, uncommon = 0, rare = 0)
    common = common.to_i
    uncommon = uncommon.to_i
    rare = rare.to_i

    puts TTMagicItems.new(common:, uncommon:, rare:)
  end

  desc "merchant_mariners", "Generate a merchant mariner encounter"
  def merchant_mariners
    puts MerchantMariners.new
  end

  desc "nautical_encounters DANGER_LEVEL (in 1..4) TRADE_ROUTE=false NUM=20", "Roll a set of nautical encounters"
  def nautical_encounters(danger_level, trade_route = nil, num = 20)
    puts Encounters::NauticalEncounter.new(danger_level, trade_route:).danger_label
    num.to_i.times do
      puts Encounters::NauticalEncounter.new(danger_level, trade_route:)
    end
  end

  desc "weather T_DAY, T_NIGHT, PRECIPITATION, WIND, PREVAILING_WIND_DIRECTION=Prevailing", "Roll weather for a season"
  def weather(day_modifier, night_modifier, precipitation, wind, prevailing = nil)
    day_modifier = day_modifier.to_i
    night_modifier = night_modifier.to_i
    precipitation = precipitation.to_i
    wind = wind.to_i

    puts Weather.new(day_modifier:, night_modifier:, precipitation:, wind:, prevailing:).roll
  end
end

Acks.start(ARGV) if File.basename($PROGRAM_NAME) == "acks.rb"
