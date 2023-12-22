# frozen_string_literal: true

class Building
  class Villa < Building
    def self.label
      "Villa"
    end

    FAMILY_SIZE = 5
    SERVANTS_BY_SIZE = {
      large: {
        cook: Dice.new.plus(1),
        maidservant: Dice.new.plus(1),
        scullion: Dice.new.plus(1),
      },
      huge: {
        cook: Dice.new.plus(1),
        maidservant: Dice.new("1d2"),
        scullion: Dice.new("1d2"),
      },
    }.freeze

    def generate_occupants
      num_occupants = Dice.new("2d4").roll

      occupants = [patrician]
      occupants << patrician if num_occupants > 1
      (3..[num_occupants, FAMILY_SIZE].min).each { occupants << dependent }
      (FAMILY_SIZE..num_occupants).each { |_i| occupants << extended }

      (1..SERVANTS_BY_SIZE[size][:cook].roll).each { occupants << Occupant.new(type: :servant, subtype: :cook) }
      (1..SERVANTS_BY_SIZE[size][:maidservant].roll).each do
        occupants << Occupant.new(type: :servant, subtype: :maidservant)
      end
      (1..SERVANTS_BY_SIZE[size][:scullion].roll).each { occupants << Occupant.new(type: :servant, subtype: :scullion) }

      (1..Dice.new("1d3").roll).each { occupants << Occupant.new(type: :guard) }
      occupants << Occupant.new(type: :fighter) if size == :huge

      occupants
    end

    VILLA_OCCUPATIONS = {
      fighter: 16,
      patrician: 100,
    }.freeze
    def patrician
      Occupant.new(type: random_weighted(VILLA_OCCUPATIONS))
    end

    def dependent
      Occupant.new(type: :dependent)
    end

    def extended
      Occupant.new(type: :patrician, subtype: :extended_family)
    end
  end
end
