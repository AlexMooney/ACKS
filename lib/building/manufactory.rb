# frozen_string_literal: true

class Building
  class Manufactory < Building
    def self.label
      "Manufactory"
    end

    attr_reader :artisan_type

    def initialize(size, type)
      @artisan_type = random_weighted(Occupant::ARTISAN_SUBTYPES)
      super
    end

    def generate_occupants
      occupants = Dice.new("2d6").roll.times.flat_map do
        [
          Occupant.new(type: :master_crafter, subtype: artisan_type),
          Occupant.new(type: :journeyman_crafter, subtype: artisan_type),
          Occupant.new(type: :journeyman_crafter, subtype: artisan_type),
          Occupant.new(type: :apprentice_crafter, subtype: artisan_type),
          Occupant.new(type: :apprentice_crafter, subtype: artisan_type),
          Occupant.new(type: :apprentice_crafter, subtype: artisan_type),
          Occupant.new(type: :apprentice_crafter, subtype: artisan_type),
        ]
      end
      occupants += Dice.new("4d6").roll.times.map do
        Occupant.new(type: :laborer, subtype: :unskilled)
      end
      occupants
    end
  end
end
