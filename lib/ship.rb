# frozen_string_literal: true

class Ship
  include Tables
  include ShipTables

  attr_accessor :flag, :crew_size, :cargo, :artillery_pieces, :passenger_type, :passenger_count, :passengers, :captain

  def initialize(flag:, skip_captain: false)
    @flag = flag
    @cargo ||= {}
    assign_artillery!
    generate_captain! unless skip_captain
  end

  def generate_passengers!(dice_expression, multiplier = 1, ethnicity:, passenger_type: nil)
    self.passenger_count = roll_dice(dice_expression) * multiplier
    self.passenger_type = passenger_type || roll_table(PASSENGER_TYPE_BY_ROLL)
    self.passengers = self.passenger_type.new(passenger_count, ethnicity:)
  end

  def generate_cargo!(dice_expression)
    @cargo = {}
    roll_dice(dice_expression).times do
      good = TradeGood.random
      lot = Cargo.new(good, 1000)
      if @cargo[lot.name]
        @cargo[lot.name].quantity += lot.quantity
      else
        @cargo[lot.name] = lot
      end
    end
  end

  def assign_artillery!
    @artillery_pieces = if rand < (cargo_value / 100_000.0) || passenger_type == Marines
                          artillery_capacity
                        else
                          0
                        end
  end

  def artillery_string
    if @artillery_pieces.positive?
      pieces_string = @artillery_pieces == 1 ? "piece" : "pieces"
      "#{@artillery_pieces} #{pieces_string} of #{artillery_weight} st artillery"
    else
      "No artillery"
    end
  end

  def artillery_capacity
    self.class.const_get(:ARTILLERY_CAPACITY)
  end

  def artillery_weight
    self.class.const_get(:ARTILLERY_WEIGHT)
  end

  def cargo_value
    @cargo.values.sum(&:price)
  end

  def <=>(other)
    cargo_value <=> other.cargo_value
  end

  def cargo_weight
    @cargo.values.sum(&:quantity)
  end

  STONES_PER_PASSENGER = 50
  def total_weight
    cargo_weight + (artillery_weight * artillery_pieces) + (passenger_count * STONES_PER_PASSENGER)
  end

  def weight_string
    "Total weight carried: #{total_weight} st"
  end

  def generate_captain!
    self.captain = Character.new(self.class::CAPTAIN,
                                 "Captain",
                                 character_class: roll_table(captain_class_table),
                                 ethnicity: flag.downcase)
  end

  def captain_class_table
    MERCHANT_CAPTAIN_CLASS_TABLE
  end

  def stat_line
    stats = self.class::STAT_LINE
    if has_bulwark?
      shp = stats.match(/(\d+)\s*SHP/)[1].to_i
      shp *= 1.05
      stats = stats.sub(/(\d+)\s*SHP/, "#{shp.round} SHP")
      stats += ", with Bulwark"
    end
    stats
  end

  def ship_class
    "#{self.class::LABEL.capitalize} ship"
  end

  def has_bulwark?
    false
  end

  def has_ram?
    false
  end

  def to_s
    cargo_list = @cargo.values.sort_by(&:price).map { |c| "  #{c}" }.join("\n")
    [
      "### #{ship_class}",
      stat_line,
      "#{crew_size}× crew, #{artillery_string}, #{weight_string}",
      captain,
      passengers,
      "Cargo worth #{cargo_value} gp weighing #{cargo_weight} st",
      cargo_list,
      "",
    ].join("\n")
  end
end
