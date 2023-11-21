#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'pry'
  gem 'thor', '~> 1.2.1'
end

require_relative './monsters'
require_relative './tables'

ROOM_TYPES = {
  6 => :empty,
  12 => :monster,
  15 => :trap,
  20 => :unique
}.freeze
TREASURE_CHANCES = {
  empty: 0.15,
  monster: 0,
  trap: 0.3,
  unique: 0
}.freeze

ENCOUNTER_LEVEL_BY_DUNGEON_LEVEL = {
  1 => { 9 => 1, 11 => 2, 12 => 3 },
  2 => { 3 => 1, 9 => 2, 11 => 3, 12 => 4 },
  3 => { 1 => 1, 3 => 2, 9 => 3, 11 => 4, 12 => 5 },
  4 => { 1 => 2, 3 => 3, 9 => 4, 11 => 5, 12 => 6 },
  5 => { 1 => 3, 3 => 4, 9 => 5, 12 => 6 },
  6 => { 1 => 4, 3 => 5, 12 => 6 }
}.freeze

Room = Struct.new('Room', :type, :monster, :trap, :treasure) do
  extend Tables

  def self.random(floor)
    room_type = roll_table(ROOM_TYPES)
    treasure_chance = TREASURE_CHANCES[room_type]
    monster = choose_monster(floor) if room_type == :monster
    trap = 'trap' if room_type == :trap
    treasure = rand < treasure_chance ? 'with treasure' : nil

    new(room_type, monster, trap, treasure)
  end

  def self.choose_monster(floor)
    encounter_level_table = ENCOUNTER_LEVEL_BY_DUNGEON_LEVEL[floor.level]
    encounter_level = roll_table(encounter_level_table)
    Monster.new(floor, encounter_level, *roll_table(DUNGEON_MONSTERS[encounter_level]))
  end

  def to_s
    stuff = "#{monster} #{trap} #{treasure} #{type == :unique ? 'unique' : nil}".squeeze(' ').strip
    stuff.empty? ? 'empty' : stuff
  end

  def <=>(other)
    if monster && other.monster
      monster <=> other.monster
    elsif monster
      -1
    elsif other.monster
      1
    else
      to_s <=> other.to_s
    end
  end
end

Floor = Struct.new('Floor', :number_of_rooms, :level) do
  attr_reader :rooms

  def assign_rooms!
    @rooms = []
    number_of_rooms.times do
      @rooms << Room.random(self)
    end
  end

  def to_s
    rooms
      .sort
      .map(&:to_s)
      .chunk_while { |a, b| a == b }
      .map { |chunk| "#{chunk.size}x #{chunk.first}" }.join("\n")
  end

  def empty_rooms
    rooms.select { |r| r.type == :empty && r.treasure.nil? }
  end
end

class DungeonStocking < Thor
  include Tables

  desc 'dungeon_stocking ROOMS LEVEL', 'Roll dungeon stocking results.'
  def dungeon_stocking(rooms, level = 1)
    floor = Floor.new(rooms.to_i, level.to_i)
    floor.assign_rooms!
    puts floor.to_s
  end
end

DungeonStocking.start(ARGV)
