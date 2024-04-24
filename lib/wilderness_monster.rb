# frozen_string_literal: true

WildernessMonster = Struct.new(:name, :total_xp, :total_spoils_value, :treasure_type, keyword_init: true)
WILDERNESS_MONSTER_BY_NAME = {} # rubocop:disable Style/MutableConstant
CSV.read("encounter_treasure_data.csv", headers: true).map do |row|
  monster = WildernessMonster.new(
    name: row["name"],
    total_xp: row["total_xp"]&.strip.to_i,
    total_spoils_value: row["total_spoils_value"]&.strip&.sub("$", "").to_i,
    treasure_type: row["treasure_type"]&.strip || "",
  )
  WILDERNESS_MONSTER_BY_NAME[row["name"]] = monster
end
WILDERNESS_MONSTER_BY_NAME.freeze

puts "Read #{WILDERNESS_MONSTER_BY_NAME.size} monsters"
