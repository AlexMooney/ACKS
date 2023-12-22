# frozen_string_literal: true

class Dice
  attr_reader :dice, :constants

  def initialize(die_string = nil)
    @dice = []
    @constants = []

    return if die_string.nil?

    num, sides = die_string.split("d")
    num.to_i.times { add_die(sides.to_i) }
  end

  def add_die(sides)
    @dice << Die.new(sides)
    self
  end

  def roll
    die_results = dice.reduce(0) do |sum, die|
      sum + die.roll
    end
    constants.sum(die_results)
  end

  def plus(num)
    @constants << num
    self
  end

  def minus(num)
    @constants << -num
    self
  end
end

class Die
  attr_reader :sides

  def initialize(sides)
    @sides = sides
  end

  def roll
    rand(1..sides)
  end
end
