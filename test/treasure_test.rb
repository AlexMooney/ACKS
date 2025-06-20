# frozen_string_literal: true

require "test_helper"

describe Treasure do
  def subject
    Treasure
  end

  it "initializes with a string of treasure types" do
    treasure = subject.new("🧪")
    assert_instance_of subject, treasure
    # 99 whatever whatever (99gp each)
    assert_match(/\d [^(]*\(\d+[csg]p.*each\)/, treasure.to_s)
  end

  it "can generate half and quarter values" do
    treasure = subject.new("🧪/2")
    assert_instance_of subject, treasure
    assert_match(/\d [^(]*\(\d+[csg]p.*each\)/, treasure.to_s)
  end

  it "can generate treasure without goods" do
    treasure = subject.new("🧪", only_coins: true)
    assert_instance_of subject, treasure
    assert_match(/\d [^(]*\(\d+[csg]p.*each\)/, treasure.to_s)
  end
end
