# frozen_string_literal: true

require "test_helper"

describe Treasure do
  def subject
    Treasure
  end

  it "initializes with a string of treasure types" do
    treasure = subject.new("🧪")
    assert_instance_of subject, treasure
    assert treasure.quantity_by_type.size.positive?
    # assert treasure.quantity_by_type.keys.first.is_a?(Treasure::Lot)
  end
end
