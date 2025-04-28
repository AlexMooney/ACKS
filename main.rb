#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/building"
require_relative "lib/building/manufactory"

puts Building.construct.description
puts
# puts Building::Townhouse.new(:large, Building::Townhouse).description
# puts Building::Townhouse.new(:large, Building::Townhouse).description
# puts Building::Store.new(:large, Building::Store).description
puts Building::Workshop.new(:large, Building::Workshop).description
