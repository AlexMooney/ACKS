# frozen_string_literal: true

class Building
  class Shop
    def self.delegated_type
      type_roll = Dice.new("1d6").roll
      if type_roll >= 3
        Workshop
      else
        Store
      end
    end
  end
end
