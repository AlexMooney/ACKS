# frozen_string_literal: true

module Tables
  def roll_table(table)
    roll = rand(1..(table.keys.max))
    roll += 1 while table[roll].nil?
    table[roll]
  end
end
