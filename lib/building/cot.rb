# frozen_string_literal: true

class Building
  class Cot < Building
    def self.label
      "Cot"
    end

    FAMILY_SIZE = 5
    def generate_occupants
      num_occupants = case size
                      when :small
                        Dice.new("1d4").roll
                      when :medium
                        Dice.new("2d3").roll
                      end

      occupants = [owner]
      occupants << spouse if num_occupants > 1
      (3..[num_occupants, FAMILY_SIZE].min).each { occupants << dependent }
      (FAMILY_SIZE..num_occupants).each { |i| occupants << servant(i) }
      occupants
    end

    COT_OCCUPATIONS_BY_SIZE = {
      small: {
        laborer: 48,
        apprentice_crafter: 89,
        journeyman_crafter: 97,
        entertainer: 99,
        mercenary: 100,
      },
      medium: {
        apprentice_crafter: 17,
        journeyman_crafter: 40,
        apprentice_merchant: 84,
        entertainer: 88,
        thief: 92,
        mercenary: 94,
        fighter: 100,
      },
    }.freeze

    def owner
      Occupant.new(type: random_weighted(COT_OCCUPATIONS_BY_SIZE[size]))
    end

    def spouse
      Occupant.new(type: :spouse)
    end

    def dependent
      Occupant.new(type: :dependent)
    end

    def servant(_index)
      Occupant.new(type: :servant, subtype: :maidservant)
    end
  end
end
