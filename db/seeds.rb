# frozen_string_literal: true

require "csv"

# Seed MagicItem table from CSV files in lib/magic_items/
MAGIC_ITEMS_DIR = Rails.root.join("lib/magic_items")
SKIP_FILES = %w[frequencies.csv potion_appearances.csv].freeze

Dir.glob(MAGIC_ITEMS_DIR.join("*.csv")).sort.each do |csv_path|
  filename = File.basename(csv_path)
  next if SKIP_FILES.include?(filename)

  # Derive rarity and item_type from filename: "common_potions.csv" => ["common", "potions"]
  parts = filename.delete_suffix(".csv").split("_")
  item_type = parts.pop
  rarity = parts.join("_") # handles "very_rare"

  CSV.foreach(csv_path, headers: true) do |row|
    MagicItem.find_or_create_by!(
      name: row["Name"],
      rarity: rarity,
      item_type: item_type,
    ) do |item|
      item.base_cost = row["Base Cost"]&.to_i
      item.apparent_value = row["Apparent Value"]
      item.share = row["Share"]&.to_i
      item.weighted_share = (row["Weighted Share"] || row["weighted share"])&.to_i
      item.description = row["Description"]
    end
  end
end

puts "Seeded #{MagicItem.count} magic items"
