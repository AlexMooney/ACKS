#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "pry"
  gem "thor", "~> 1.2.1"
  gem "tty-table"
end

require_relative "tables"

class SettlementEncounters < Thor
  include Tables

  desc "laying_low DAYS", "Generate a series of encounters laying low for DAYS days"
  def laying_low(days)
    days = days.to_i
    encounters = []
    days.times do |day|
      encounters << [day + 1, rand(1..100)] if rand(1..6) >= 5
    end
    encounters.each do |encounter|
      puts "Day #{encounter[0]}: #{encounter[1]}"
    end
  end
end

SettlementEncounters.start(ARGV)
