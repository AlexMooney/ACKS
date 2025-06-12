# frozen_string_literal: true

class Treasure
  class Lot
    attr_reader :description, :amount, :gold_value, :weight

    def initialize(description, amount, gold_value, coin_weight)
      @description = description
      @amount = amount
      @gold_value = gold_value
      @coin_weight = coin_weight
      @weight = case coin_weight
                when Integer
                  coin_weight
                when Proc
                  coin_weight.call(self).round
                else
                  raise ArgumentError, "Invalid coin weight: #{coin_weight.inspect}"
                end
      raise "#{description} #{amount} #{gold_value} #{coin_weight.inspect}" if weight.zero?
    end

    def to_s
      "#{amount} #{description} (#{[gold_label, weight_label].compact.join(' & ')} each)"
    end

    def <=>(other)
      [other.gold_per_weight, description] <=> [gold_per_weight, other.description]
    end

    def group_attributes
      [description, weight, gold_value]
    end

    def +(other)
      raise "Descriptions do not match" if description != other.description
      raise "Values do not match" if gold_value != other.gold_value

      Lot.new(description, amount + other.amount, gold_value, @coin_weight)
    end

    def zero
      self.class.new(description, 0, gold_value, @coin_weight)
    end

    def gold_per_weight
      1.0 * gold_value / weight
    end

    private

    def gold_label
      if (gold_value * 100) % 1 != 0
        "#{(gold_value * 100).to_i}cp"
      elsif (gold_value * 10) % 1 != 0
        "#{(gold_value * 10).to_i}sp"
      else
        "#{gold_value.to_i}gp"
      end
    end

    def weight_label
      if weight == 1
        nil
      elsif (weight % 1000).zero?
        "#{weight / 1000} st"
      elsif (weight % 500).zero?
        if weight > 1000
          "#{(weight / 1000).to_i}½ st"
        else
          "½ st"
        end
      else # TODO: item weights
        "#{weight / 1000.0} st"
      end
    end
  end
end
