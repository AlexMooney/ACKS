# frozen_string_literal: true

require "test_helper"

describe Weather do
  it "returns a string table of weather for a season" do
    weather = Weather.new(day_modifier: 0, night_modifier: 0, precipitation_modifier: 0, wind_modifier: 0)
    result = weather.roll

    assert_instance_of String, result
    assert_match(/Date.+Day.+Night.+Precipitation.+Day Wind.+Night Wind/, result)
  end
end
