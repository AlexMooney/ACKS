# frozen_string_literal: true

class Building
  class Townhouse < Building
    def self.label
      "Townhouse"
    end

    FAMILY_SIZE = 5
    def generate_occupants
      occupants = []
      if size == :huge
        house_number = 1
        sqft = 7500
        while sqft > 2500
          new_occupants = case Dice.new("1d7").roll
                          when 6, 7
                            sqft -= 2500
                            Townhouse.new(:large, Townhouse).generate_occupants.map do |occupant|
                              occupant.type = "Large Townhouse ##{house_number} #{occupant.type}"
                              occupant
                            end
                          else
                            sqft -= 1000
                            Townhouse.new(:medium, Townhouse).generate_occupants.map do |occupant|
                              occupant.type = "Medium Townhouse ##{house_number} #{occupant.type}"
                              occupant
                            end
                          end
          occupants.concat new_occupants
          house_number += 1
        end

        while sqft > 1000
          sqft -= 1000
          new_occupants = Townhouse.new(:medium, Townhouse).generate_occupants.map do |occupant|
            occupant.type = "Medium Townhouse ##{house_number} #{occupant.type}"
            occupant
          end
          occupants.concat new_occupants
        end
      else
        num_occupants = case size
                        when :medium
                          Dice.new("2d4").roll
                        when :large
                          Dice.new("2d6").roll
                        else
                          puts "Invalid size #{size.inspect}"
                        end

        occupants << owner
        occupants << spouse if num_occupants > 1
        (3..[num_occupants, FAMILY_SIZE].min).each { occupants << dependent }
        (FAMILY_SIZE..num_occupants).each { |i| occupants << servant(i) }
      end
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
      }.freeze,
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
