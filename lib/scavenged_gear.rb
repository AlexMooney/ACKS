# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "pry"
  gem "thor", "~> 1.2.1"
end

class SalvagedItem
  attr_accessor :name, :value, :faults, :penalties

  def initialize(name, value)
    @name = name
    @value = value.to_f
    @faults = Set.new
    @penalties = Hash.new(0)
    determine_faults!
  end

  def to_s
    penalties_str = penalties.map do |k, v|
      case k
      when :breaks
        "breaks on #{v} or lower"
      when :rattles
        "cannot move silently"
      when :encumbrance
        "+#{v} stone encumbrance"
      else
        "-#{v} to #{k}"
      end
    end.join(", ")
    if faults.empty?
      "#{name} (#{value.round(2)} gp)"
    else
      "#{faults.join(' & ')} #{name} (#{value.round(2)} gp; #{penalties_str})"
    end
  end

  private

  def determine_faults!
    roll = rand(1..20)
    case roll
    when 1..2 # No faults
      nil
    when 19..20 # Roll twice
      determine_faults!
      determine_faults!
    else
      self.value *= 0.67

      add_fault(roll)
    end
  end

  def add_fault(roll)
    new_fault = name_the_fault(roll)
    if (old_fault = faults.detect { |f| f.end_with?(new_fault) })
      faults.delete(old_fault)
      faults << "very #{old_fault}"
    else
      faults << new_fault
    end
  end
end

class SharpWeapon < SalvagedItem
  def name_the_fault(roll)
    case roll
    when 3..6
      penalties[:damage] += 1
      "dented"
    when 7..10
      penalties[:damage] += 1
      "rusty"
    when 11..14
      penalties[:attack] += 1
      "off balance"
    when 15..16
      penalties[:initiative] += 1
      "loose grip"
    when 17..18
      penalties[:breaks] += 1
      "shoddy"
    end
  end
end

class BluntWeapon < SalvagedItem
  def name_the_fault(roll)
    case roll
    when 3..6
      penalties[:damage] += 1
      "soft head"
    when 7..10
      penalties[:damage] += 1
      "wobbly head"
    when 11..14
      penalties[:attack] += 1
      "off balance"
    when 15..16
      penalties[:initiative] += 1
      "wobbly head"
    when 17..18
      penalties[:breaks] += 1
      "shoddy"
    end
  end
end

class RangedWeapon < SalvagedItem
  def name_the_fault(roll)
    case roll
    when 3..6
      penalties[:damage] += 1
      "cracked"
    when 7..10
      penalties[:damage] += 1
      "bent"
    when 11..14
      penalties[:attack] += 1
      "warped"
    when 15..18
      penalties[:breaks] += 1
      "shoddy"
    end
  end
end

class Armor < SalvagedItem
  def name_the_fault(roll)
    case roll
    when 3..6
      penalties[:encumbrance] += 1
      "broken straps"
    when 7..10
      penalties[:rattles] += 1
      "rattles if moved"
    when 11..14
      penalties[:ac] += 1
      "dented/rotting"
    when 15..16
      penalties[:ac] += 1
      "makeshift"
    when 17..18
      name_the_fault(rand(3..16)) # Reroll results that are irrelevant to the item: armor can't break
    end
  end
end

class Equipment < SalvagedItem
  def name_the_fault(roll)
    case roll
    when 3..6
      penalties[:encumbrance] += 1
      "broken straps"
    when 7..10
      penalties[:rattles] += 1
      "rattles if moved"
    when 11..14
      penalties[:breaks] += 1
      "dented/rotting"
    when 15..16
      penalties[:breaks] += 1
      "makeshift"
    when 17..18
      penalties[:breaks] += 1
      "torn"
    end
  end
end

class SalvagedGear < Thor
  desc "sharp_weapon name value count=1", "Generated sharp weapons"
  def sharp_weapon(name, value, count = "1")
    generate_results(name, value, count, SharpWeapon)
  end

  desc "blunt_weapon name value count=1", "Generated blunt weapons"
  def blunt_weapon(name, value, count = "1")
    generate_results(name, value, count, BluntWeapon)
  end

  desc "ranged_weapon name value count=1", "Generated ranged weapons"
  def ranged_weapon(name, value, count = "1")
    generate_results(name, value, count, RangedWeapon)
  end

  desc "armor name value count=1", "Generated armor"
  def armor(name, value, count = "1")
    generate_results(name, value, count, Armor)
  end

  desc "equipment name value count=1", "Generated equipment"
  def equipment(name, value, count = "1")
    generate_results(name, value, count, Equipment)
  end

  private

  def generate_results(name, value, count, klass)
    results = count.to_i.times.map do
      klass.new(name, value).to_s
    end

    results.tally.each do |k, v|
      if v > 1
        puts "#{v}x #{k}"
      else
        puts k
      end
    end
  end
end

SalvagedGear.start(ARGV)
