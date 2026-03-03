# MagicItem Model Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Scaffold a `MagicItem` AR model and seed it from the 32 magic item CSV files so `bin/setup` populates the database.

**Architecture:** Rails scaffold generates the model, migration, and basic tests. Seeds read each `lib/magic_items/{rarity}_{type}.csv`, derive rarity/type from the filename, and create records. Potion CSVs have an extra `Description` column; all others share the same 5-column layout.

**Tech Stack:** Rails 8.1, SQLite, CSV stdlib, Minitest

---

### Task 1: Scaffold MagicItem model

**Files:**
- Create: `app/models/magic_item.rb`
- Create: `db/migrate/*_create_magic_items.rb`
- Create: `test/models/magic_item_test.rb`

**Step 1: Generate the scaffold**

Run:
```bash
bin/rails generate model MagicItem name:string rarity:string item_type:string base_cost:integer apparent_value:string share:integer weighted_share:integer description:string
```

**Step 2: Run migration**

Run: `bin/rails db:migrate`

**Step 3: Verify**

Run: `bundle exec rake test`
Expected: All tests pass (new model test is empty scaffold)

**Step 4: Commit**

```bash
git add app/models/magic_item.rb db/migrate/*_create_magic_items.rb test/models/magic_item_test.rb db/schema.rb
git commit -m "Scaffold MagicItem model with migration"
```

---

### Task 2: Write seed logic

**Files:**
- Modify: `db/seeds.rb`

**Step 1: Implement seeds**

Replace `db/seeds.rb` with:

```ruby
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
```

Key details:
- `parts.pop` gets the last segment as item_type; `parts.join("_")` handles "very_rare" correctly since `["very", "rare", "potions"].pop` gives "potions" and `["very", "rare"].join("_")` gives "very_rare"
- The `weighted share` header is lowercase in some CSVs (`common_potions.csv` has `weighted share`), others have `Weighted Share`. Check both.
- `find_or_create_by!` on name+rarity+item_type makes seeds idempotent.

**Step 2: Run seeds**

Run: `bin/rails db:seed`
Expected: Prints "Seeded 1544 magic items" (approximate — exact count may vary)

**Step 3: Verify in console**

Run: `bin/rails runner "puts MagicItem.group(:rarity).count.to_yaml"`
Expected: Counts per rarity, e.g. common ~128, uncommon ~193, rare ~378, very_rare ~436, legendary ~409

**Step 4: Commit**

```bash
git add db/seeds.rb
git commit -m "Add MagicItem seeds from CSV files"
```

---

### Task 3: Write model tests

**Files:**
- Modify: `test/models/magic_item_test.rb`

**Step 1: Write tests**

```ruby
# frozen_string_literal: true

require "test_helper"

class MagicItemTest < ActiveSupport::TestCase
  VALID_RARITIES = %w[common uncommon rare very_rare legendary].freeze
  VALID_ITEM_TYPES = %w[potions rings scrolls implements misc swords weapons armor].freeze

  setup do
    # Seeds must have been run for these tests
    Rails.application.load_seed if MagicItem.count.zero?
  end

  test "seeds populate magic items" do
    assert MagicItem.count > 1000, "Expected at least 1000 magic items, got #{MagicItem.count}"
  end

  test "all rarities present" do
    rarities = MagicItem.distinct.pluck(:rarity).sort
    assert_equal VALID_RARITIES.sort, rarities
  end

  test "all item types present" do
    item_types = MagicItem.distinct.pluck(:item_type).sort
    assert_equal VALID_ITEM_TYPES.sort, item_types
  end

  test "no duplicate name+rarity+item_type" do
    dupes = MagicItem.group(:name, :rarity, :item_type).having("COUNT(*) > 1").count
    assert_empty dupes, "Found duplicate items: #{dupes.keys.inspect}"
  end

  test "every item has a name and share" do
    nameless = MagicItem.where(name: [nil, ""])
    assert_equal 0, nameless.count, "Items without names: #{nameless.pluck(:id)}"

    shareless = MagicItem.where(share: [nil, 0])
    assert_equal 0, shareless.count, "Items without share: #{shareless.pluck(:id, :name)}"
  end

  test "potions have descriptions" do
    potions_without_desc = MagicItem.where(item_type: "potions", description: [nil, ""])
    assert_equal 0, potions_without_desc.count,
                 "Potions without descriptions: #{potions_without_desc.pluck(:name)}"
  end

  test "seeds are idempotent" do
    count_before = MagicItem.count
    Rails.application.load_seed
    assert_equal count_before, MagicItem.count
  end
end
```

**Step 2: Run tests**

Run: `bundle exec ruby -Ilib -Itest test/models/magic_item_test.rb`
Expected: All tests PASS

**Step 3: Run full suite**

Run: `bundle exec rake test`
Expected: All tests pass, no regressions

**Step 4: Commit**

```bash
git add test/models/magic_item_test.rb
git commit -m "Add MagicItem model tests for seeds and data integrity"
```
