require_relative 'lib/building'
require_relative 'lib/building/manufactory'

puts Building.construct.description
puts Building::Manufactory.new(:huge, Building::Manufactory).description
