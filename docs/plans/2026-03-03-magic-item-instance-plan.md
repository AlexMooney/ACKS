# MagicItemInstance Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a MagicItemInstance model that persists resolved magic items (e.g., "Scroll of Warding vs. Dragons") with a FK to their template MagicItem, plus a MagicItemGenerator service to roll and resolve them.

**Architecture:** MagicItemInstance stores an optional override_name and override_description that fall back to the linked MagicItem via display methods. A MagicItemGenerator service (following the CharacterGenerator pattern) handles rolling items by rarity, resolving template patterns, and returning unsaved instances. Polymorphic owner allows attaching instances to Characters or other models.

**Tech Stack:** Rails 8.1, SQLite, Minitest, existing Tables module + SpellScroll/ScrollCreatureWarding classes from lib/

---

### Task 1: Create MagicItemInstance migration and model

**Files:**
- Create: `db/migrate/TIMESTAMP_create_magic_item_instances.rb` (via generator)
- Create: `app/models/magic_item_instance.rb`
- Modify: `app/models/magic_item.rb`
- Modify: `app/models/character.rb`

**Step 1: Generate the migration**

Run:
```bash
bin/rails generate migration CreateMagicItemInstances magic_item:references owner:references{polymorphic} override_name:string override_description:text
```

Then edit the generated migration to make owner nullable:

```ruby
class CreateMagicItemInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_item_instances do |t|
      t.references :magic_item, null: false, foreign_key: true
      t.references :owner, polymorphic: true, null: true
      t.string :override_name
      t.text :override_description

      t.timestamps
    end
  end
end
```

**Step 2: Run the migration**

Run: `bin/rails db:migrate`
Expected: Migration succeeds, schema.rb updated with magic_item_instances table.

**Step 3: Write the MagicItemInstance model**

```ruby
# app/models/magic_item_instance.rb
class MagicItemInstance < ApplicationRecord
  belongs_to :magic_item
  belongs_to :owner, polymorphic: true, optional: true

  def display_name
    override_name || magic_item.name
  end

  def display_description
    override_description || magic_item.description
  end
end
```

**Step 4: Add associations to MagicItem**

In `app/models/magic_item.rb`, add:

```ruby
has_many :magic_item_instances, dependent: :destroy
```

**Step 5: Add association to Character**

In `app/models/character.rb`, add:

```ruby
has_many :magic_item_instances, as: :owner, dependent: :destroy
```

**Step 6: Commit**

```bash
git add db/migrate/*_create_magic_item_instances.rb app/models/magic_item_instance.rb app/models/magic_item.rb app/models/character.rb db/schema.rb
git commit -m "Add MagicItemInstance model with polymorphic owner"
```

---

### Task 2: Write model tests and fixtures

**Files:**
- Create: `test/fixtures/magic_item_instances.yml`
- Create: `test/models/magic_item_instance_test.rb`

**Step 1: Write fixtures**

```yaml
# test/fixtures/magic_item_instances.yml

# Fixture that uses override_name (resolved template)
warding_vs_dragons:
  magic_item: creature_warding
  override_name: "Scroll of Warding vs. Dragons"
  override_description: "Wards against dragons in a 30' radius"

# Fixture that falls back to magic_item name (non-template)
potion_healing:
  magic_item: healing_potion
```

We also need magic_item fixtures now. Update `test/fixtures/magic_items.yml`:

```yaml
# test/fixtures/magic_items.yml

creature_warding:
  name: "Scroll of Creature Warding"
  rarity: common
  item_type: scrolls
  base_cost: 500
  apparent_value: "500 gp"
  share: 4

healing_potion:
  name: "Potion of Healing"
  rarity: common
  item_type: potions
  base_cost: 200
  apparent_value: "200 gp"
  share: 10
  description: "Heals 1d6+1 hit points"

spell_scroll_3:
  name: "Spell Scroll (3 levels)"
  rarity: uncommon
  item_type: scrolls
  base_cost: 1000
  apparent_value: "1,000 gp"
  share: 6

versus_x_sword:
  name: "Sword +1, +2 versus X"
  rarity: rare
  item_type: swords
  base_cost: 5000
  apparent_value: "5,000 gp"
  share: 12
```

**Step 2: Write the failing tests**

```ruby
# test/models/magic_item_instance_test.rb
# frozen_string_literal: true

require "test_helper"

class MagicItemInstanceTest < ActiveSupport::TestCase
  test "belongs to a magic item" do
    instance = magic_item_instances(:warding_vs_dragons)
    assert_equal magic_items(:creature_warding), instance.magic_item
  end

  test "display_name returns override_name when present" do
    instance = magic_item_instances(:warding_vs_dragons)
    assert_equal "Scroll of Warding vs. Dragons", instance.display_name
  end

  test "display_name falls back to magic_item.name when override is nil" do
    instance = magic_item_instances(:potion_healing)
    assert_equal "Potion of Healing", instance.display_name
  end

  test "display_description returns override_description when present" do
    instance = magic_item_instances(:warding_vs_dragons)
    assert_equal "Wards against dragons in a 30' radius", instance.display_description
  end

  test "display_description falls back to magic_item.description when override is nil" do
    instance = magic_item_instances(:potion_healing)
    assert_equal "Heals 1d6+1 hit points", instance.display_description
  end

  test "owner is optional" do
    instance = MagicItemInstance.new(magic_item: magic_items(:healing_potion))
    assert instance.valid?
  end

  test "magic_item is required" do
    instance = MagicItemInstance.new
    refute instance.valid?
  end

  test "can belong to a character" do
    instance = MagicItemInstance.new(
      magic_item: magic_items(:healing_potion),
      owner: characters(:one),
    )
    assert instance.valid?
    assert_equal "Character", instance.owner_type
  end
end
```

**Step 3: Run the tests**

Run: `bundle exec ruby -Itest test/models/magic_item_instance_test.rb`
Expected: All 8 tests pass.

**Step 4: Run full test suite to check for regressions**

Run: `bundle exec rake test`
Expected: All tests pass. The new magic_items.yml fixtures may affect `magic_item_test.rb` — check that its seed-based setup still works.

**Step 5: Commit**

```bash
git add test/fixtures/magic_item_instances.yml test/fixtures/magic_items.yml test/models/magic_item_instance_test.rb
git commit -m "Add MagicItemInstance model tests and fixtures"
```

---

### Task 3: Write MagicItemGenerator service

**Files:**
- Create: `app/services/magic_item_generator.rb`
- Create: `test/services/magic_item_generator_test.rb`

**Step 1: Write the failing tests**

The generator needs seeded MagicItem data to work (it rolls from DB records). Tests should seed if needed.

```ruby
# test/services/magic_item_generator_test.rb
# frozen_string_literal: true

require "test_helper"

class MagicItemGeneratorTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_seed if MagicItem.count.zero?
  end

  test "returns an array of MagicItemInstance records" do
    instances = MagicItemGenerator.new(common: 1).generate
    assert_kind_of Array, instances
    assert_instance_of MagicItemInstance, instances.first
  end

  test "returns unsaved records" do
    instances = MagicItemGenerator.new(common: 1).generate
    assert instances.all?(&:new_record?)
  end

  test "generates requested number of items per rarity" do
    instances = MagicItemGenerator.new(common: 3, uncommon: 2).generate
    common_count = instances.count { |i| i.magic_item.rarity == "common" }
    uncommon_count = instances.count { |i| i.magic_item.rarity == "uncommon" }
    assert_equal 3, common_count
    assert_equal 2, uncommon_count
  end

  test "each instance has a magic_item reference" do
    instances = MagicItemGenerator.new(common: 5).generate
    instances.each do |instance|
      assert_not_nil instance.magic_item
      assert_instance_of MagicItem, instance.magic_item
    end
  end

  test "resolves Scroll of Creature Warding into specific creature" do
    # Generate enough common scrolls to likely hit a warding scroll
    found = false
    50.times do
      instances = MagicItemGenerator.new(common: 10).generate
      warding = instances.find { |i| i.magic_item.name == "Scroll of Creature Warding" }
      if warding
        assert_match(/\AScroll of Warding vs\. /, warding.display_name)
        refute_equal "Scroll of Creature Warding", warding.display_name
        found = true
        break
      end
    end
    assert found, "Expected to generate at least one Scroll of Creature Warding in 500 common items"
  end

  test "resolves Spell Scroll template into specific spells" do
    found = false
    50.times do
      instances = MagicItemGenerator.new(common: 10).generate
      scroll = instances.find { |i| i.magic_item.name&.match?(/\ASpell Scroll/) }
      if scroll
        assert_match(/(Arcane|Divine) Scroll in .+ with /, scroll.display_name)
        found = true
        break
      end
    end
    assert found, "Expected to generate at least one Spell Scroll in 500 common items"
  end

  test "resolves versus X weapon into specific creature" do
    found = false
    50.times do
      instances = MagicItemGenerator.new(rare: 10).generate
      vs_item = instances.find { |i| i.magic_item.name&.include?("versus X") }
      if vs_item
        refute_includes vs_item.display_name, "versus X"
        assert_match(/versus /, vs_item.display_name)
        found = true
        break
      end
    end
    assert found, "Expected to generate at least one 'versus X' item in 500 rare items"
  end

  test "non-template items have nil override_name" do
    instances = MagicItemGenerator.new(common: 20).generate
    non_template = instances.find { |i| !i.magic_item.name.match?(/Spell Scroll|Creature Warding|versus X/) }
    assert_not_nil non_template, "Expected at least one non-template item"
    assert_nil non_template.override_name
  end

  test "returns empty array when all quantities are zero" do
    instances = MagicItemGenerator.new(common: 0).generate
    assert_empty instances
  end
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec ruby -Itest test/services/magic_item_generator_test.rb`
Expected: FAIL — `NameError: uninitialized constant MagicItemGenerator`

**Step 3: Write the MagicItemGenerator service**

```ruby
# app/services/magic_item_generator.rb
# frozen_string_literal: true

class MagicItemGenerator
  include Tables

  RARITIES = %w[common uncommon rare very_rare legendary].freeze
  TEMPLATE_PATTERNS = {
    spell_scroll: /\ASpell Scroll \((\d+) levels?\)\z/,
    creature_warding: "Scroll of Creature Warding",
    versus_x: / versus X/,
  }.freeze

  def initialize(**quantities)
    @quantities = quantities
  end

  def generate
    instances = []
    @quantities.each do |rarity, count|
      rarity_str = rarity.to_s
      next unless RARITIES.include?(rarity_str) && count.positive?

      count.times do
        magic_item = roll_item(rarity_str)
        override_name = resolve_name(magic_item.name)
        instances << MagicItemInstance.new(
          magic_item: magic_item,
          override_name: override_name,
        )
      end
    end
    instances
  end

  private

  def roll_item(rarity)
    type = roll_type(rarity)
    items = MagicItem.where(rarity: rarity, item_type: type)
    weights = items.to_h { |item| [item, item.weighted_share || item.share] }
    roll_weighted(weights)
  end

  def roll_type(rarity)
    type_weights = TTMagicItems.type_by_rarity[rarity]
    roll_weighted(type_weights)
  end

  def resolve_name(name)
    if (match = name.match(TEMPLATE_PATTERNS[:spell_scroll]))
      SpellScroll.new(match[1].to_i).roll_details
    elsif name == TEMPLATE_PATTERNS[:creature_warding]
      MagicItems::ScrollCreatureWarding.new.roll_details
    elsif name.match?(TEMPLATE_PATTERNS[:versus_x])
      creature = MagicItems::ScrollCreatureWarding.new.roll_details.sub("Scroll of Warding vs. ", "")
      name.sub(" versus X", " versus #{creature}")
    end
  end
end
```

**Step 4: Run tests to verify they pass**

Run: `bundle exec ruby -Itest test/services/magic_item_generator_test.rb`
Expected: All 9 tests pass.

**Step 5: Run full test suite**

Run: `bundle exec rake test`
Expected: All tests pass.

**Step 6: Commit**

```bash
git add app/services/magic_item_generator.rb test/services/magic_item_generator_test.rb
git commit -m "Add MagicItemGenerator service with template resolution"
```

---

### Task 4: Wire up controller to use MagicItemGenerator

**Files:**
- Modify: `app/controllers/magic_items_controller.rb`
- Modify: `app/views/magic_items/generate.html.erb`
- Modify: `test/controllers/magic_items_controller_test.rb`

**Step 1: Update the controller**

Replace the TTMagicItems call with MagicItemGenerator:

```ruby
# app/controllers/magic_items_controller.rb
# frozen_string_literal: true

class MagicItemsController < ApplicationController
  RARITIES = %i[common uncommon rare very_rare legendary].freeze

  def generate
    @quantities = RARITIES.index_with { |r| params[r].to_i }

    if @quantities.values.any?(&:positive?)
      @magic_item_instances = MagicItemGenerator.new(**@quantities).generate
    end
  end
end
```

**Step 2: Update the view**

```erb
<%# app/views/magic_items/generate.html.erb %>
<% content_for :title, "Generate Magic Items" %>

<h1>Generate Magic Items</h1>

<%= form_with url: generate_magic_items_path, method: :get, class: "character-form" do |f| %>
  <fieldset>
    <legend>Quantities by Rarity</legend>
    <div class="field-row">
      <% MagicItemsController::RARITIES.each do |rarity| %>
        <div class="field field-narrow">
          <%= f.label rarity, rarity.to_s.titleize %>
          <%= f.number_field rarity, value: @quantities[rarity], min: 0 %>
        </div>
      <% end %>
    </div>
  </fieldset>

  <div class="form-actions">
    <%= f.submit "Generate", class: "btn" %>
  </div>
<% end %>

<% if @magic_item_instances %>
  <div class="magic-items-results">
    <h2>Results</h2>
    <% @magic_item_instances.group_by { |i| i.magic_item.rarity }.each do |rarity, instances| %>
      <h3><%= rarity.titleize %></h3>
      <ul>
        <% instances.sort_by(&:display_name).each do |instance| %>
          <li><%= instance.display_name %></li>
        <% end %>
      </ul>
    <% end %>
  </div>
<% end %>
```

**Step 3: Update controller tests**

The existing tests check for `@magic_items` and `.magic-items-results`. Update to work with the new instance-based output:

```ruby
# test/controllers/magic_items_controller_test.rb
# frozen_string_literal: true

require "test_helper"

class MagicItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.load_seed if MagicItem.count.zero?
  end

  test "generate with no params renders form" do
    get generate_magic_items_url
    assert_response :success
    assert_select "form"
    assert_select "input[name='common']"
  end

  test "generate with quantities returns results" do
    get generate_magic_items_url, params: { common: 3, uncommon: 1 }
    assert_response :success
    assert_select "form"
    assert_select ".magic-items-results"
  end

  test "generate with all zeros renders form without results" do
    get generate_magic_items_url, params: { common: 0, uncommon: 0, rare: 0, very_rare: 0, legendary: 0 }
    assert_response :success
    assert_select ".magic-items-results", false
  end
end
```

**Step 4: Run controller tests**

Run: `bundle exec ruby -Itest test/controllers/magic_items_controller_test.rb`
Expected: All 3 tests pass.

**Step 5: Run full test suite**

Run: `bundle exec rake test`
Expected: All tests pass.

**Step 6: Commit**

```bash
git add app/controllers/magic_items_controller.rb app/views/magic_items/generate.html.erb test/controllers/magic_items_controller_test.rb
git commit -m "Wire MagicItemGenerator into controller and view"
```
