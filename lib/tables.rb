# frozen_string_literal: true

module Tables
  def roll_table(table, roll = nil)
    return roll_array_table(table, roll) if table.is_a?(Array)

    roll ||= rand(1..(table.keys.max))
    roll += 1 while table[roll].nil?
    result = table[roll]

    if result.is_a?(Hash)
      roll_table(result)
    else
      result
    end
  end

  def roll_array_table(table, roll = nil)
    roll ||= rand(0..(table.size - 1))
    table[roll]
  end

  def roll_dice(dice_string)
    return dice_string if dice_string.is_a? Integer
    return 0 if dice_string.nil? || dice_string.empty?

    dice_string.split(/[+-]/).sum do |dice_substring|
      quantity, sides = dice_substring.split("d")
      if sides
        quantity.to_i.times.map { rand(1..sides.to_i) }.sum
      elsif dice_substring.end_with?("%")
        rand(1..100) <= dice_substring.to_i ? 1 : 0
      else
        quantity.to_i
      end
    end
  end
end
