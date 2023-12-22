#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/building"
require_relative "lib/building/manufactory"

puts Building.construct.description
