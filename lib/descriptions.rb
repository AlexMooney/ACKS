# frozen_string_literal: true

DWARF_BUILD = {
  1 => "Small",
  3 => "Slim",
  7 => "Average",
  11 => "Broad",
  13 => "Large",
  18 => "Huge",
}.freeze

BUILD_HEIGHT_MODIFIER = Hash.new(1.0).merge(
  "Small" => 0.9,
  "Large" => 1.1,
  "Huge" => 1.2,
).freeze

BUILD_WEIGHT_MODIFIER = Hash.new(1.0).merge(
  "Small" => 0.7,
  "Slim" => 0.8,
  "Broad" => 1.2,
  "Large" => 1.3,
  "Huge" => 1.75,
).freeze

DWARF_EYE_COLOR = {
  4 => "Light Brown",
  6 => "Dark Grey",
  8 => "Light Grey",
  10 => "Dark Grey-Brown",
  12 => "Light Grey-Brown",
  14 => "Light Green",
  16 => "Dark Green",
  18 => "Dark Hazel",
  20 => "Light Hazel",
}.freeze

DWARF_SKIN_COLOR = {
  4 => "Medium Brown",
  8 => "Dark Brown",
  12 => "Very Dark Brown",
  16 => "Ochre",
  20 => "Sienna",
}.freeze

DWARF_HAIR_COLOR = {
  7 => "Black",
  11 => "Dark Chestnut",
  14 => "Light Chestnut",
  17 => "Dark Grey",
  20 => "Light Grey",
}.freeze

DWARF_HAIR_TEXTURE = {
  1 => "Curly",
  2 => "Wavy",
}.freeze

HUMAN_BUILD = {
  1 => "Small",
  4 => "Slim",
  8 => "Average",
  10 => "Broad",
  12 => "Large",
  18 => "Huge",
}.freeze

HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY = {
  "celdorean" => [2, 1.05],
  "corcani" => [1, 1.03],
  "jutlander" => [3, 1.125],
  "kemeshi" => [0, 0.98],
  "kyrsean" => [1, 1.065],
  "kushtu" => [3, 1.05],
  "nicean" => [1, 1.065],
  "opelenean" => [0, 1.065],
  "rornish" => [3, 1.09],
  "shebatean" => [1, 1.0],
  "somirean" => [0, 1.03],
  "syrnasosi" => [0, 1.0],
  "skysos" => [-2, 1.0],
  "tirenean" => [2, 1.065],
  "zaharan" => [2, 0.975],
}.freeze

HUMAN_EYE_COLOR_BY_ETHNICITY = { # rubocop:disable Style/MutableConstant
  "celdorean" => {
    6 => "Black",
    9 => "Dark Brown",
    11 => "Medium Brown",
    13 => "Light Brown",
    14 => "Medium Green",
    17 => "Dark Hazel",
    20 => "Medium Hazel",
  },
  "corcani" => {
    2 => "Medium Blue-Grey",
    4 => "Light Blue-Grey",
    6 => "Medium Brown",
    8 => "Light Brown",
    10 => "Dark Grey",
    12 => "Medium Grey",
    14 => "Dark Grey-Brown",
    16 => "Medium Grey-Brown",
    17 => "Medium Green-Gray",
    18 => "Light Green-Gray",
    19 => "Medium Hazel",
    20 => "Light Hazel",
  },
  "jutlander" => {
    2 => "Medium Blue",
    5 => "Light Blue",
    7 => "Medium Blue-Grey",
    9 => "Light Blue-Grey",
    11 => "Medium Blue-Green",
    13 => "Light Blue-Green",
    14 => "Medium Grey",
    15 => "Light Grey",
    16 => "Very Light Grey",
    17 => "Medium Green",
    19 => "Light Green",
    20 => "Light Violet",
  },
  "kemeshi" => {
    5 => "Black",
    10 => "Dark Brown",
    15 => "Medium Brown",
    20 => "Light Brown",
  },
  "kyrsean" => {
    4 => "Dark Brown",
    8 => "Medium Brown",
    12 => "Light Brown",
    16 => "Dark Hazel",
    20 => "Medium Hazel",
  },
  "kushtu" => {
    20 => "Black",
  },
  "nicean" => {
    4 => "Dark Brown",
    8 => "Medium Brown",
    10 => "Light Brown",
    12 => "Dark Green",
    14 => "Medium Green",
    17 => "Dark Hazel",
    20 => "Medium Hazel",
  },
  "rornish" => {
    1 => "Medium Blue",
    4 => "Light Blue",
    5 => "Medium Blue-Grey",
    7 => "Light Blue-Grey",
    9 => "Light Brown",
    10 => "Medium Green",
    13 => "Light Green",
    14 => "Medium Green-Grey",
    16 => "Light Green-Grey",
    17 => "Medium Hazel",
    20 => "Light Hazel",
  },
  "shebatean" => {
    10 => "Black",
    20 => "Dark Brown",
  },
  "skysos" => {
    9 => "Black",
    10 => "Light Blue",
    13 => "Dark Brown",
    16 => "Medium Brown",
    19 => "Light Brown",
    20 => "Medium Grey",
  },
  "syranasosi" => {
    8 => "Black",
    10 => "Dark Brown",
    13 => "Medium Brown",
    16 => "Light Brown",
    18 => "Dark Hazel",
    20 => "Medium Hazel",
  },
  "tirenean" => {
    3 => "Medium Blue-Grey",
    6 => "Dark Brown",
    9 => "Medium Brown",
    11 => "Light Brown",
    13 => "Dark Grey",
    15 => "Medium Grey",
    17 => "Dark Grey-Brown",
    20 => "Medium Grey-Brown",
  },
  "zaharan" => {
    3 => "Dark Amber",
    6 => "Medium Amber",
    10 => "Dark Brown",
    13 => "Dark Grey-Brown",
    16 => "Medium Grey-Brown",
    18 => "Dark Green-Brown",
    20 => "Medium Green-Brown",
  },
}
HUMAN_EYE_COLOR_BY_ETHNICITY["opelenean"] = HUMAN_EYE_COLOR_BY_ETHNICITY["krysean"]
HUMAN_EYE_COLOR_BY_ETHNICITY["somirean"] = HUMAN_EYE_COLOR_BY_ETHNICITY["shebatean"]
HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.freeze

HUMAN_SKIN_COLOR_BY_ETHNICITY = { # rubocop:disable Style/MutableConstant
  "celdorean" => {
    10 => "Light Brown",
    20 => "Light Olive",
  },
  "corcani" => {
    6 => "Very Light Brown",
    20 => "Light Brown",
  },
  "jutlander" => {
    20 => "Pale",
  },
  "kemeshi" => {
    10 => "Dark Brown",
    20 => "Medium Brown",
  },
  "kyrsean" => {
    10 => "Medium Brown",
    20 => "Light Brown",
  },
  "kushtu" => {
    7 => "Dark Brown",
    14 => "Medium Brown",
    20 => "Brown-Black",
  },
  "rornish" => {
    6 => "Very Light Brown",
    8 => "Light Brown",
    14 => "Freckled Pale",
    20 => "Pale",
  },
  "shebatean" => {
    6 => "Dark Brown",
    13 => "Medium Brown",
    20 => "Dark Olive",
  },
  "skysos" => {
    6 => "Dark Ocher",
    13 => "Medium Ocher",
    20 => "Light Ocher",
  },
  "somirean" => {
    5 => "Dark Ocher",
    10 => "Medium Ocher",
    15 => "Dark Olive",
    20 => "Reddish Olive",
  },
  "syrnasosi" => {
    4 => "Dark Brown",
    8 => "Medium Brown",
    10 => "Dark Ocher",
    12 => "Medium Ocher",
    16 => "Dark Olive",
    20 => "Medium Olive",
  },
  "tirenean" => {
    5 => "Very Light Brown",
    20 => "Light Brown",
  },
  "zaharan" => {
    6 => "Copper",
    13 => "Sienna Olive",
    20 => "Reddish Brown",
  },
}
HUMAN_SKIN_COLOR_BY_ETHNICITY["opelenean"] = HUMAN_SKIN_COLOR_BY_ETHNICITY["kemeshi"]
HUMAN_SKIN_COLOR_BY_ETHNICITY["nicean"] = HUMAN_SKIN_COLOR_BY_ETHNICITY["krysean"]
HUMAN_SKIN_COLOR_BY_ETHNICITY.freeze

HUMAN_HAIR_COLOR_BY_ETHNICITY = { # rubocop:disable Style/MutableConstant
  "celdorean" => {
    5 => "Dark Auburn",
    10 => "Medium Auburn",
    15 => "Rufous Brown",
    20 => "Brown-Black",
  },
  "corcani" => {
    3 => "Dark Auburn",
    6 => "Medium Auburn",
    10 => "Black",
    12 => "Dark Blonde",
    14 => "Dark Brown",
    16 => "Golden Brown",
    18 => "Rufous Brown",
    20 => "Dark Red",
  },
  "jutlander" => {
    5 => "Dark Blonde",
    10 => "Golden Blonde",
    12 => "Platinum Blonde",
    16 => "Golden Brown",
    20 => "Rufous Brown",
  },
  "kemeshi" => {
    10 => "Black",
    20 => "Dark Brown",
  },
  "kushtu" => {
    20 => "Black",
  },
  "nicean" => {
    5 => "Black",
    10 => "Ash Brown",
    15 => "Dark Brown",
    20 => "Dark Blonde",
  },
  "opelenean" => {
    9 => "Black",
    10 => "Ash Brown",
    19 => "Dark Brown",
    20 => "Dark Blonde",
  },
  "rornish" => {
    2 => "Dark Auburn",
    5 => "Medium Auburn",
    8 => "Golden Blonde",
    11 => "Strawberry Blonde",
    14 => "Golden Brown",
    16 => "Rufous Brown",
    18 => "Dark Red",
    20 => "Medium Red",
  },
  "somerian" => {
    8 => "Black",
    12 => "Blue-Black",
    20 => "Dark Brown",
  },
  "syrnasosi" => {
    4 => "Dark Auburn",
    8 => "Black",
    12 => "Dark Brown",
    16 => "Rufous Brown",
    20 => "Brown-Black",
  },
  "zaharan" => {
    10 => "Black",
    20 => "Blue-Black",
  },
}
HUMAN_HAIR_COLOR_BY_ETHNICITY["kyrsean"] = HUMAN_HAIR_COLOR_BY_ETHNICITY["celdorean"]
HUMAN_HAIR_COLOR_BY_ETHNICITY["shebatean"] = HUMAN_HAIR_COLOR_BY_ETHNICITY["kemeshi"]
HUMAN_HAIR_COLOR_BY_ETHNICITY["tirenean"] = HUMAN_HAIR_COLOR_BY_ETHNICITY["nicean"]
HUMAN_HAIR_COLOR_BY_ETHNICITY["skysis"] = HUMAN_HAIR_COLOR_BY_ETHNICITY["somirean"]
HUMAN_HAIR_COLOR_BY_ETHNICITY.freeze

HUMAN_HAIR_TEXTURE_BY_ETHNICITY = { # rubocop:disable Style/MutableConstant
  "celdorean" => {
    10 => "Straight",
    20 => "Wavy",
  },
  "jutlander" => {
    16 => "Straight",
    20 => "Wavy",
  },
  "kemeshi" => {
    10 => "Curly",
    20 => "Wavy",
  },
  "krysean" => {
    5 => "Curly",
    12 => "Straight",
    20 => "Wavy",
  },
  "kushtu" => {
    20 => "Tightly Curled",
  },
  "skysos" => {
    20 => "Straight",
  },
}
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["corcani"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["celdorean"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["somirean"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["celdorean"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["tirenean"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["celdorean"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["rornish"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["jutlander"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["opelenean"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["kemeshi"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["shebatean"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["kemeshi"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["nicean"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["krysean"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["syrnasosi"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["krysean"]
HUMAN_HAIR_TEXTURE_BY_ETHNICITY["zaharan"] = HUMAN_HAIR_TEXTURE_BY_ETHNICITY["krysean"]
HUMAN_HAIR_COLOR_BY_ETHNICITY.freeze
