# frozen_string_literal: true

require_relative "../acks"

describe Acks do
  describe "building" do
    it "puts a building description" do
      output = capture_io do
        Acks.start(["building"])
      end

      assert_match(/\ASize:.*Type.*Occupants \(\d+\)/, output.join)
    end
  end

  describe "magic_items" do
    it "puts magic items" do
      output = capture_io do
        Acks.start(%w[magic_items 1 1 1])
      end
      assert_match(/Common magic items:.*\nUncommon magic items:.*\nRare magic items:/, output.join)
    end
  end

  describe "merchant_mariners" do
    it "puts a merchant mariner encounter" do
      output = capture_io do
        Acks.start(["merchant_mariners"])
      end

      output = output.join
      assert_match(/ship/, output)
      assert_match(/crew/, output)
      assert_match(/captain/, output)
      assert_match(/Cargo worth \d+ gp weighing \d+ st/, output)
    end
  end
end
