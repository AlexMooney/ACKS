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

  describe "nautical_encounters" do
    it "puts a nautical encounter" do
      output = capture_io do
        Acks.start(%w[nautical_encounters 1 1])
      end

      output = output.join
      assert_match(/Civilized/, output)
      assert_match(/Sea/, output)
    end
  end

  describe "weather" do
    it "puts weather for a month" do
      output = capture_io do
        # TTY::Table uses ioctl for the width of the terminal output but StringIO doesn't have it, so stub it.
        # See https://github.com/piotrmurach/tty-screen/issues/11#issuecomment-675463240
        # See https://github.com/piotrmurach/tty-prompt/blob/2c2c44e8b1d4affe9926bc87c3740000dcf7f2f7/lib/tty/prompt/test.rb#L10-L17
        def $stdout.ioctl(*) = 80

        Acks.start(%w[weather 1 1 1 1])
      end

      output = output.join
      assert_match(/Date/, output)
      assert_match(/Day/, output)
      assert_match(/Night/, output)
      assert_match(/Precipitation/, output)
      assert_match(/Wind/, output)
    end
  end
end
