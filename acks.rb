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

    puts TTMagicItems.format_items(TTMagicItems.roll_magic_items(common:, uncommon:, rare:))
  end
end

Acks.start(ARGV)
