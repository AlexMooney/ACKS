# frozen_string_literal: true

DWARF_BUILD = {
  1 => 'Small',
  3 => 'Slim',
  7 => 'Average',
  11 => 'Broad',
  13 => 'Large',
  18 => 'Huge'
}.freeze

BUILD_HEIGHT_MODIFIER = Hash.new(1.0).merge(
  'Small' => 0.9,
  'Large' => 1.1,
  'Huge' => 1.2
).freeze

BUILD_WEIGHT_MODIFIER = Hash.new(1.0).merge(
  'Small' => 0.7,
  'Slim' => 0.8,
  'Broad' => 1.2,
  'Large' => 1.3,
  'Huge' => 1.75
).freeze

DWARF_EYE_COLOR = {
  4 => 'Light Brown',
  6 => 'Dark Grey',
  8 => 'Light Grey',
  10 => 'Dark Grey-Brown',
  12 => 'Light Grey-Brown',
  14 => 'Light Green',
  16 => 'Dark Green',
  18 => 'Dark Hazel',
  20 => 'Light Hazel'
}.freeze

DWARF_SKIN_COLOR = {
  4 => 'Medium Brown',
  8 => 'Dark Brown',
  12 => 'Very Dark Brown',
  16 => 'Ochre',
  20 => 'Sienna'
}.freeze

DWARF_HAIR_COLOR = {
  7 => 'Black',
  11 => 'Dark Chestnut',
  14 => 'Light Chestnut',
  17 => 'Dark Grey',
  20 => 'Light Grey'
}.freeze

DWARF_HAIR_TEXTURE = {
  1 => 'Curly',
  2 => 'Wavy'
}.freeze
