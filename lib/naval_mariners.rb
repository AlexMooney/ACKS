# frozen_string_literal: true

# 1 1-rower 3 30 - 3rd
# 2–3 2-rower 5 90 10 4th
# 4–6 2.5-rower 10 120 10 5th
# 7–10 3-rower 15 170 15 6th
# 11–14 4-rower 15 180 75 6th
# 15–17 5-rower 20 300 75 6th
# 18–19 6-rower 20 336 100 6th
# 20 8-rower 50 440 150 7th

class NavalMariners
  include Tables

  attr_accessor :number_of_ships, :ships, :commodore, :flag

  SHIP_TYPES_BY_ROLL = {
    1 => Ship::Galley1,
    3 => Ship::Galley2,
    6 => Ship::Galley25,
    10 => Ship::Galley3,
    14 => Ship::Galley4,
    17 => Ship::Galley5,
    19 => Ship::Galley6,
    20 => Ship::Galley8,
  }.freeze
  LAIR_CHANCE = 0.25
  def initialize(flag: nil, lair: nil)
    @flag = flag || roll_table(Ship::RANDOM_FLAG_SYRNASOS)
    @lair = (lair.nil? ? rand < LAIR_CHANCE : lair)

    @number_of_ships = (@lair ? roll_dice("1d6!") : 1)
    @ships = []
    @number_of_ships.times do
      @ships << roll_table(SHIP_TYPES_BY_ROLL).new(flag: @flag)
    end
    @ships = @ships.sort

    return unless @lair

    @commodore = Character.new(@ships.first.captain.level + 1,
                               "Commodore",
                               character_class: roll_table(captain_class_table),
                               ethnicity: @flag.downcase)
  end

  def to_s
    if @commodore
      "#{flag} fleet of #{@number_of_ships} ships\n#{@commodore}\n\n#{ships.map(&:to_s).join("\n")}"
    else
      "#{flag} #{ships.first.ship_class}\n#{ships.first}"
    end
  end

  def captain_class_table
    Ship::ShipTables::NAVAL_CAPTAIN_CLASS_TABLE
  end
end
