# frozen_string_literal: true

class Cargo
  attr_accessor :trade_good, :quantity

  def self.random_lot(quantity = 1000)
    good = TradeGood.random
    new(good, quantity)
  end

  def initialize(trade_good, quantity)
    @trade_good = trade_good
    @quantity = quantity
  end

  def to_s
    "#{quantity} st of #{name} in #{container} worth #{price} gp"
  end

  def price
    (price_per_stone * quantity).round
  end

  def container
    trade_good.container
  end

  def name
    trade_good.name
  end

  def price_per_stone
    trade_good.price_per_stone
  end
end
