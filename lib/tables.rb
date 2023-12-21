# frozen_string_literal: true

module Tables
  def roll_table(table, roll = nil)
    roll ||= rand(1..(table.keys.max))
    roll += 1 while table[roll].nil?
    table[roll]
  end

  def roll_dice(dice_string)
    dice_string.split('+').sum do |dice_substring|
      quantity, sides = dice_substring.split('d')
      if sides
        sides, keep = sides.split('k')
        keep ||= sides
        rolled = quantity.to_i.times.map { rand(1..sides.to_i) }.sort
        rolled.last(keep.to_i).sum
      else
        quantity.to_i
      end
    end
  end
end
