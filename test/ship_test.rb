# frozen_string_literal: true

require "test_helper"

describe "Galley generation" do
  it "Galley1 generation" do
    ship = Ship::Galley1.new(flag: "Tirenean")
    assert_instance_of Ship::Galley1, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end

  it "Galley2 generation" do
    ship = Ship::Galley2.new(flag: "Tirenean")
    assert_instance_of Ship::Galley2, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end

  it "Galley25 generation" do
    ship = Ship::Galley25.new(flag: "Tirenean")
    assert_instance_of Ship::Galley25, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end

  it "Galley3 generation" do
    ship = Ship::Galley3.new(flag: "Tirenean")
    assert_instance_of Ship::Galley3, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end

  it "Galley4 generation" do
    ship = Ship::Galley4.new(flag: "Tirenean")
    assert_instance_of Ship::Galley4, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end

  it "Galley5 generation" do
    ship = Ship::Galley5.new(flag: "Tirenean")
    assert_instance_of Ship::Galley5, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end

  it "Galley6 generation" do
    ship = Ship::Galley6.new(flag: "Tirenean")
    assert_instance_of Ship::Galley6, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end

  it "Galley8 generation" do
    ship = Ship::Galley8.new(flag: "Tirenean")
    assert_instance_of Ship::Galley8, ship
    assert_equal "Tirenean", ship.flag
    assert_instance_of Treasure, ship.treasure
    assert_instance_of Character, ship.captain
  end
end
