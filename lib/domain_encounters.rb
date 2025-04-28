#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "pry"
  gem "thor", "~> 1.2.1"
end

require_relative "monsters"
require_relative "tables"

class DomainEncounters < Thor
  include Tables

  private

  def choose_creature(terrain)
    table = WILDERNESS_MONSTERS["#{terrain.capitalize}Enc"]
    result = roll_table(table)
    while result.start_with?("[")
      binding.pry if WILDERNESS_MONSTERS[result[1..-2]].nil?
      result = roll_table(WILDERNESS_MONSTERS[result[1..-2]])
    end
    result
  end

  def recon_roll
    rand(1..6) + rand(1..6)
  end

  def reaction
    roll = rand(1..6) + rand(1..6)
    label = case roll
            when 2 then "Hostile, pillage"
            when 3..5 then "Unfriendly, opportunistic"
            when 6..8 then "Neutral, exploratory"
            when 9..11 then "Mercantilist, trade"
            when 12 then "Friendly, help"
            end
    "#{label} (#{roll})"
  end
end

DomainEncounters.start(ARGV)
