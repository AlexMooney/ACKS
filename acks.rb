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

  desc "nautical_encounters DANGER_LEVEL (in 0..4) TRADE_ROUTE=false NUM=20", "Roll a set of nautical encounters"
  def nautical_encounters(danger_level, trade_route = nil, num = 20)
    num.to_i.times do
      puts Encounters::NauticalEncounter.new(danger_level, trade_route:)
    end
  end
end

Acks.start(ARGV) if File.basename($PROGRAM_NAME) == "acks.rb"
