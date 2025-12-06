# frozen_string_literal: true

class Building
  class Workshop < Building
    def self.label
      "Workshop"
    end

    attr_reader :artisan_type

    def initialize(size, type)
      @artisan_type = random_weighted(Occupant::ARTISAN_SUBTYPES)
      super
    end

    def generate_occupants
      case size
      when :small
        Occupant.new(type: :journeyman_crafter, subtype: artisan_type)
      when :medium
        master_and_staff
      when :large
        master_and_staff + master_and_staff
      end
    end

    def master_and_staff
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
  end
end
