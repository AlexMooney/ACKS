class Building
  class Shop < Building
    def self.label
      "Shop"
    end

    def initialize(size, type)
      super(size, type)
      type_roll = Dice.new('1d6').roll
      self.type = :workshop if type_roll >= 3

      # TODO Generate artisan type
    end

    def generate_occupants
      occupants << owner


      
      num_occupants = case size
      when :small
        1
      when :medium
        Dice.new('2d6').roll
      end

      occupants = owners
      # TODO: add other occupants

    end

    def owners
      leaders = case size
      when :small
        type == :shop ? [:apprentice_merchant] : [:journeyman_crafter]
      when :medium
        type == :shop ? [:licensed_merchant] : [:master_artisan]
      when :large
        type == :shop ? (Dice.new('1d100').roll < 17 ? [:venturer] :  [:master_merchant]) : [:master_artisan, :master_artisan]
      end

      leaders.each.map { |occupation| Occupant.new(type: occupation) }
    end
  end
end
