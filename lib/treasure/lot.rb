# frozen_string_literal: true

class Treasure
  class Lot
    # Each lot is based on a type of coin but rolls for the actual treasure type.
    # multiple lots of the same type are accumulated in a hash by Treasure
    include Tables
    include SpecialTreasureTables

    attr_reader :type, :amount

    def initialize(coin_type)
      raw_type, raw_amount = fetch_data(coin_type)
      @type = sub_internal_rolls(raw_type)
      @amount = roll_dice(raw_amount)
    end

    private

    def fetch_data(coin_type)
      case coin_type.downcase
      when "cp"
        CP_GOODS_TABLE.sample
      when "sp"
        SP_GOODS_TABLE.sample
      when "ep"
        EP_GOODS_TABLE.sample
      when "gp"
        GP_GOODS_TABLE.sample
      when "pp"
        PP_GOODS_TABLE.sample
      when "ornamentals"
        [roll_table(GEMS_TABLE, roll_dice("2d20")), 1]
      when "gems"
        [roll_table(GEMS_TABLE, roll_dice("1d100")), 1]
      when "brilliants"
        [roll_table(GEMS_TABLE, roll_dice("1d100 + 80")), 1]
      when "jewelry"
        JEWELRY_TABLE
      else
        raise ArgumentError, "Unknown coin type: #{coin_type}"
      end
    end

    def sub_internal_rolls(string)
      while string.include?("{")
        # Replace placeholders with actual values
        string = string.sub(/{([^}]+)}/) do
          match_content = ::Regexp.last_match(1)
          if match_content.include?("d")
            # Handle dice notation
            roll_dice(match_content)
          else
            # Handle sub table lookups
            self.class.const_get(match_content.upcase).sample
          end
        end
      end
      string
    end
  end
end
