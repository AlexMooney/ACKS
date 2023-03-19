class Dice
  attr_reader :dice, :constants
  def initialize(die_string)
    @dice = []
    @constands = []

    num, sides = die_string.split('d')
    num.to_i.times { add_die(sides.to_i) }
  end

  def add_die(sides)
    @dice << Die.new(sides)
  end

  def roll(num)
    @dice = []
    dice.reduce do |sum, die|
      sum + die.roll
    end
    constants.reduce(sum, :+)
  end

  def plus(num)
    @constants << num
  end

  def minus(num)
    @constants << -num
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
