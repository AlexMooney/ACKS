# frozen_string_literal: true

module Tables
  def roll_table(table, roll = nil)
    case table
    when Array
      roll ||= rand(0...table.size)
    when Hash
      roll ||= rand(1..(table.keys.max))
      roll = table.keys.select { |key| key >= roll }.min if table[roll].nil?
    else
      raise "Invalid table type #{table.class}"
    end
    result = table[roll]
    case result
    when Array, Hash
      roll_table(result)
    else
      result
    end
  end

  def roll_weighted(value_by_weight)
    total_weight = value_by_weight.values.sum
    roll = rand(1..total_weight)
    cumulative_weight = 0
    value_by_weight.each do |value, weight|
      cumulative_weight += weight
      return value if roll <= cumulative_weight
    end
    raise "Unexpected roll weight"
  end

  def roll_dice(dice_string)
    return dice_string if dice_string.is_a? Numeric
    return 0 if dice_string.nil? || dice_string.empty?
    return rand(1..100) <= dice_string.to_i ? 1 : 0 if dice_string.end_with?("%")

    dice_string.split("+").sum do |dice_substring|
      dice_substring.split("*").reduce(1) do |product, dice_subsubstring|
        quantity, sides = dice_subsubstring.split("d")
        product * if sides
                    sides, keep = sides.split("k")
                    explodes = sides.end_with?("!")
                    keep ||= quantity
                    rolled = quantity.to_i.times.map do
                      result = die = rand(1..sides.to_i)
                      while explodes && die == sides.to_i
                        die = rand(1..sides.to_i)
                        result += die
                      end
                      result
                    end.sort
                    rolled.last(keep.to_i).sum
                  elsif quantity.include?(".")
                    quantity.to_f
                  else
                    quantity.to_i
                  end
      end
    end
  end
end
