# frozen_string_literal: true

class Building
  class Store < Building
    def self.label
      "Merchant's Store"
    end

    attr_reader :merchant_occupation

    def initialize(size, type)
      @merchant_occupation = random_weighted(Occupant::MERCHANT_OCCUPATIONS)
      super
    end

    def generate_occupants
      case size
      when :small
        case Dice.new("1d3").roll
        when 1
          [Occupant.new(type: :apprentice_merchant, subtype: merchant_occupation)]
        else
          [Occupant.new(type: :peddler, subtype: merchant_occupation)]
        end
      when :medium
        licensed_merchant_and_staff
      when :large
        boss = case Dice.new("1d4")
               when 1
                 Occupant.new(type: :venturer)
               else
                 Occupant.new(type: :master_merchant, subtype: merchant_occupation)
               end
        [boss] + licensed_merchant_and_staff + licensed_merchant_and_staff
      end
    end

    def licensed_merchant_and_staff
      [
        Occupant.new(type: :licensed_merchant, subtype: merchant_occupation),
        Occupant.new(type: :apprentice_merchant, subtype: merchant_occupation),
        Occupant.new(type: :apprentice_merchant, subtype: merchant_occupation),
      ]
    end
  end
end
