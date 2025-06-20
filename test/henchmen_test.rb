# frozen_string_literal: true

require "test_helper"

describe "Henchmen" do
  it "generates all of the henchmen that show up in a market" do
    henchmen = Henchmen.new(market_class: 1)
    assert(henchmen.henchmen.all? { |h| h.is_a?(Character) })
    assert(henchmen.henchmen.all? { |h| h.level.between?(0, 4) })
    henchmen.to_s
  end
end
