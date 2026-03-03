# Magic Item Generator UI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a web page at `/magic_items/generate` where users enter quantities per rarity, hit Generate, and see randomly rolled magic items — with the form always visible and quantities preserved for the next batch.

**Architecture:** A single controller action (`MagicItemsController#generate`) handles both the empty form and results. GET params carry the rarity quantities so the page is bookmarkable and the form repopulates. `TTMagicItems` does the actual generation. No persistence.

**Tech Stack:** Rails 8.1, ERB views, TTMagicItems (existing legacy generator), Minitest

---

### Task 1: Route and controller

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/magic_items_controller.rb`
- Create: `test/controllers/magic_items_controller_test.rb`

**Step 1: Write failing tests**

Create `test/controllers/magic_items_controller_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class MagicItemsControllerTest < ActionDispatch::IntegrationTest
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

**Step 2: Run tests to verify they fail**

Run: `bundle exec ruby -Ilib -Itest test/controllers/magic_items_controller_test.rb`
Expected: FAIL (route/controller don't exist)

**Step 3: Add route**

In `config/routes.rb`, add before the `root` line:

```ruby
resources :magic_items, only: [] do
  collection do
    get :generate
  end
end
```

**Step 4: Create controller**

Create `app/controllers/magic_items_controller.rb`:

```ruby
# frozen_string_literal: true

class MagicItemsController < ApplicationController
  RARITIES = %i[common uncommon rare very_rare legendary].freeze

  def generate
    @quantities = RARITIES.index_with { |r| params[r].to_i }

    if @quantities.values.any?(&:positive?)
      @magic_items = TTMagicItems.new(**@quantities)
    end
  end
end
```

Key details:
- `@quantities` is always set (hash of rarity → integer), used to repopulate the form
- `@magic_items` is only set when at least one quantity is positive
- `TTMagicItems.new` accepts keyword args `common:`, `uncommon:`, etc. and returns an object with `magic_items_by_rarity` (hash of symbol → array of strings)

**Step 5: Create a minimal view** (just enough to pass tests)

Create `app/views/magic_items/generate.html.erb`:

```erb
<% content_for :title, "Generate Magic Items" %>

<h1>Generate Magic Items</h1>

<div class="paper">
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

  <% if @magic_items %>
    <div class="magic-items-results">
      <h2>Results</h2>
      <% @magic_items.magic_items_by_rarity.each do |rarity, items| %>
        <% next if items.empty? %>
        <h3><%= rarity.to_s.titleize %></h3>
        <ul>
          <% items.sort.each do |item| %>
            <li><%= item %></li>
          <% end %>
        </ul>
      <% end %>
    </div>
  <% end %>
</div>
```

**Step 6: Run tests to verify they pass**

Run: `bundle exec ruby -Ilib -Itest test/controllers/magic_items_controller_test.rb`
Expected: All 3 tests PASS

**Step 7: Run full suite**

Run: `bundle exec rake test`
Expected: All tests pass

**Step 8: Commit**

```bash
git add config/routes.rb app/controllers/magic_items_controller.rb app/views/magic_items/generate.html.erb test/controllers/magic_items_controller_test.rb
git commit -m "Add magic item generator page with route, controller, and view"
```

---

### Task 2: Home page link

**Files:**
- Modify: `app/views/home/index.html.erb`

**Step 1: Add link**

Add to the `home-links` list in `app/views/home/index.html.erb`:

```erb
<li><%= link_to "Generate Magic Items", generate_magic_items_path %></li>
```

**Step 2: Run full suite**

Run: `bundle exec rake test`
Expected: All tests pass

**Step 3: Commit**

```bash
git add app/views/home/index.html.erb
git commit -m "Add magic items link to home page"
```

---

### Task 3: Verify and polish

**Step 1: Manual smoke test**

Start server: `bin/rails server`
Visit: `http://localhost:3000/magic_items/generate`

Verify:
- Form renders with 5 number fields defaulting to 0
- Enter "3" for common, "2" for uncommon, hit Generate
- Results appear grouped by rarity under the form
- Form still shows "3" and "2" (quantities preserved)
- Hit Generate again — new random results appear
- Enter all zeros — no results section shown

**Step 2: Run rubocop**

Run: `bundle exec rubocop app/controllers/magic_items_controller.rb app/views/magic_items/generate.html.erb test/controllers/magic_items_controller_test.rb`
Expected: No offenses. Fix any found.

**Step 3: Run full suite one more time**

Run: `bundle exec rake test`
Expected: All tests pass

**Step 4: Commit any fixes**
