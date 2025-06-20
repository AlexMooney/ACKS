# frozen_string_literal: true

require "test_helper"

class Dummy
  include Tables
end

describe Tables do
  attr_reader :dummy

  def setup
    @dummy = Dummy.new
  end

  describe "roll_dice" do
    it "returns any integer input verbatim" do
      assert_equal 22, dummy.roll_dice(22)
      assert_equal 0, dummy.roll_dice(0)
      assert_equal(-1, dummy.roll_dice(-1))
    end

    it "returns 0 if the input is empty" do
      assert_equal 0, dummy.roll_dice("")
      assert_equal 0, dummy.roll_dice(nil)
    end

    it "rolls equal or under percentage chance" do
      assert_equal 0, dummy.roll_dice("0%")
      assert_includes 0..1, dummy.roll_dice("50%")
      assert_equal 1, dummy.roll_dice("100%")
    end

    it "supports multiple dice" do
      assert_equal 5, dummy.roll_dice("5d1")
      assert_includes 3..18, dummy.roll_dice("3d6")
    end

    it "supports multiple dice keeping the top results" do
      assert_equal 2, dummy.roll_dice("5d1k2")
      assert_includes 3..18, dummy.roll_dice("5d6k3")
    end

    it "support multiplication" do
      assert_equal 4, dummy.roll_dice("2d1*2d1")
      assert_includes [10, 20], dummy.roll_dice("1d2*10")
    end

    it "supports addition" do
      assert_equal 4, dummy.roll_dice("2d1+2d1")
      assert_includes 13..28, dummy.roll_dice("3d6+10")
    end

    it "supports exploding dice" do
      result = nil
      100.times do
        result = dummy.roll_dice("1d6!")
        break if result > 6
      end
      assert_includes 7.., result
    end
  end

  describe "roll_table" do
    it "picks a random value from an array" do
      result = dummy.roll_table([0, 1, 2])
      assert_includes [0, 1, 2], result
    end

    it "can be sent a predefined result" do
      result = dummy.roll_table([0, 1, 2], dummy.roll_dice("2d1"))
      assert_equal 2, result
    end

    it "picks a random value from a hash with integer CDF keys" do
      table = { 1 => "A", 2 => "B", 5 => "C" }
      result = dummy.roll_table(table)
      assert_includes %w[A B C], result
    end

    it "supports nested hash tables" do
      table = { 1 => { 1 => "A", 2 => "B" }, 2 => { 1 => "C", 2 => "D" } }
      result = dummy.roll_table(table)
      assert_includes %w[A B C D], result
    end

    it "supports nested array tables" do
      table = [%w[A B], %w[C D]]
      result = dummy.roll_table(table)
      assert_includes %w[A B C D], result
    end
  end
end
