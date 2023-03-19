class Building
  class Townhouse < Building
    def self.label
      "Townhouse"
    end

    FAMILY_SIZE = 5
    def generate_occupants
      num_occupants = case size
      when :medium
        Dice.new('2d4').roll
      when :large
        Dice.new('2d6').roll
      end

      occupants = [owner]
      occupants << spouse if num_occupants > 1
      (3..[num_occupants, FAMILY_SIZE].min).each { occupants << dependent }
      (FAMILY_SIZE..num_occupants).each_with_index { |i| occupants << servant(i) }
      occupants
    end

    TOWNHOUSE_OCCUPATIONS_BY_SIZE = {
      medium: {
        journeyman_crafter: 18,
        master_crafter: 40,
        apprentice_merchant: 54,
        licensed_merchant: 79,
        master_merchant: 86,
        specialist: 94,
        entertainer: 96,
        thief: 98,
        fighter: 100,
      }.freeze,
      large: {
        master_crafter: 31,
        master_merchant: 67,
        specialist: 85,
        thief: 95,
        fighter: 100,
      }.freeze
    }.freeze

    def owner
      Occupant.new(type: random_weighted(TOWNHOUSE_OCCUPATIONS_BY_SIZE[size]))
    end

    def spouse
      Occupant.new(type: :spouse)
    end

    def dependent
      Occupant.new(type: :dependent)
    end

    def servant(index)
      case index
      when 6
        Occupant.new(type: :servant, subtype: :scullion)
      when 7
        Occupant.new(type: :servant, subtype: :cook)
      else
        Occupant.new(type: :servant, subtype: :maidservant)
      end
    end
  end
end
