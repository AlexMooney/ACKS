# Identity + Descriptions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extend `CharacterGenerator` to populate identity (sex, alignment, ethnicity, name, template) and physical description (build, height, weight, appearance, features) fields on the `Character` model.

**Architecture:** `CharacterGenerator` (app/services/character_generator.rb) orchestrates generation by referencing data constants from legacy modules (`CharacterLegacy::ClassTables`, `CharacterLegacy::Descriptions::*`, `CharacterLegacy::Names`). Private methods group concerns: identity, physical build, appearance, features. The `Character` model stays a plain AR record.

**Tech Stack:** Rails 8.1, Minitest, SQLite, legacy `Tables` module for dice rolling

---

### Task 1: Identity — sex, alignment, ethnicity, template

**Files:**
- Modify: `app/services/character_generator.rb`
- Test: `test/services/character_generator_test.rb`

**Step 1: Write failing tests**

Add these tests to `test/services/character_generator_test.rb`:

```ruby
test "generates sex based on class" do
  # Bladedancer is always female
  10.times do
    character = CharacterGenerator.new(character_class: "Bladedancer", level: 1).generate
    assert_equal "female", character.sex
  end
end

test "generates alignment" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  assert_includes %w[Lawful Neutral Chaotic], character.alignment
end

test "generates ethnicity from valid set" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  valid = CharacterLegacy::Descriptions::Human::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys
  assert_includes valid, character.ethnicity
end

test "dwarven class gets dwarven ethnicity" do
  character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
  assert_equal "dwarven", character.ethnicity
end

test "elven class gets elven ethnicity" do
  character = CharacterGenerator.new(character_class: "Elven Spellsword", level: 1).generate
  assert_equal "elven", character.ethnicity
end

test "generates template as 3-18" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  assert_includes 3..18, character.template
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: 6 new tests FAIL (sex/alignment/ethnicity/template are nil)

**Step 3: Implement identity generation**

In `app/services/character_generator.rb`, add these constants and methods, and update `generate`:

```ruby
class CharacterGenerator
  include Tables
  include CharacterLegacy::Names

  STATS = %w[STR INT WIL DEX CON CHA].freeze
  HUMAN_ETHNICITIES = CharacterLegacy::Descriptions::Human::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys.freeze
  RANDOM_ALIGNMENT = CharacterLegacy::Descriptions::Descriptions::RANDOM_ALIGNMENT
  SEX_BY_CLASS = CharacterLegacy::ClassTables::SEX_BY_CLASS

  # ... existing initialize stays the same ...

  def generate
    stats = roll_stats
    sex = roll_sex
    ethnicity = roll_ethnicity
    Character.new(
      level: @level,
      character_class: @character_class,
      class_type: @class_type,
      template: roll_die(3).sum,
      alignment: roll_table(RANDOM_ALIGNMENT),
      sex: sex,
      ethnicity: ethnicity,
      name: random_name(ethnicity, sex),
      **stats,
    )
  end

  private

  # ... existing roll_stats, roll_die ...

  def roll_sex
    SEX_BY_CLASS[@character_class].sample
  end

  def roll_ethnicity
    if @character_class.start_with?("Dwarven")
      "dwarven"
    elsif @character_class.start_with?("Elven")
      "elven"
    else
      HUMAN_ETHNICITIES.sample
    end
  end
end
```

Note: `RANDOM_ALIGNMENT` is defined in the `Descriptions` module directly (not nested under `Human`). Check where it actually lives — it's at `CharacterLegacy::Descriptions::RANDOM_ALIGNMENT`. Since `Descriptions` is a module on `CharacterLegacy`, reference it as `CharacterLegacy::Descriptions::RANDOM_ALIGNMENT`.

For the `Names` include: `CharacterLegacy::Names` provides instance methods like `celdorean_name(sex)` and the dispatcher `random_name(ethnicity, sex)`. Including it gives `CharacterGenerator` access to these methods. The name methods also use `roll_table` which is already available via `include Tables`.

**Step 4: Run tests to verify they pass**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add app/services/character_generator.rb test/services/character_generator_test.rb
git commit -m "Add identity generation: sex, alignment, ethnicity, name, template"
```

---

### Task 2: Physical build — build, height, weight

**Files:**
- Modify: `app/services/character_generator.rb`
- Test: `test/services/character_generator_test.rb`

**Step 1: Write failing tests**

```ruby
test "generates build for human character" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  valid_builds = CharacterLegacy::Descriptions::Human::HUMAN_BUILD.values.uniq
  assert_includes valid_builds, character.build
end

test "generates height in reasonable range" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  # Shortest possible: ~47 inches (small female skysos). Tallest: ~89 inches (huge male jutlandic)
  assert_includes 45..90, character.height_inches
end

test "generates weight in reasonable range" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  # Lightest: ~40 lbs (small female). Heaviest: ~400 lbs (huge male)
  assert_includes 40..450, character.weight_lbs
end

test "non-human ethnicity skips physical description" do
  character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
  assert_nil character.build
  assert_nil character.height_inches
  assert_nil character.weight_lbs
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: New tests FAIL (build/height/weight are nil for humans)

**Step 3: Implement physical build**

Add a `stat_bonus` helper and physical build methods to `CharacterGenerator`:

```ruby
BONUS_BY_STAT = CharacterLegacy::Stats::BONUS_BY_STAT
HUMAN_BUILD = CharacterLegacy::Descriptions::Human::HUMAN_BUILD
HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY = CharacterLegacy::Descriptions::Human::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY
BUILD_HEIGHT_MODIFIER = CharacterLegacy::Descriptions::Descriptions::BUILD_HEIGHT_MODIFIER
BUILD_WEIGHT_MODIFIER = CharacterLegacy::Descriptions::Descriptions::BUILD_WEIGHT_MODIFIER
```

In `generate`, after rolling stats and identity, add conditional physical description for humans:

```ruby
def generate
  stats = roll_stats
  sex = roll_sex
  ethnicity = roll_ethnicity

  physical = if HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.key?(ethnicity)
               roll_physical(stats, sex, ethnicity)
             else
               {}
             end

  Character.new(
    level: @level,
    character_class: @character_class,
    class_type: @class_type,
    template: roll_die(3).sum,
    alignment: roll_table(RANDOM_ALIGNMENT),
    sex: sex,
    ethnicity: ethnicity,
    name: random_name(ethnicity, sex),
    **stats,
    **physical,
  )
end
```

Private methods:

```ruby
def stat_bonus(value)
  roll_table(BONUS_BY_STAT, value)
end

def male?(sex_string)
  sex_string.downcase.start_with?("m")
end

def roll_physical(stats, sex, ethnicity)
  str_bonus = stat_bonus(stats[:str])
  build_roll = roll_die(2).sum + (2 * str_bonus)
  build = roll_table(HUMAN_BUILD, build_roll)

  height_mod, weight_mod = HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY[ethnicity]
  base_height = male?(sex) ? 60 : 55
  height = ((base_height + roll_die(2).sum + height_mod) * BUILD_HEIGHT_MODIFIER[build]).round

  base_weight = male?(sex) ? 110 : 90
  weight = ((base_weight + roll_die(8).sum) * BUILD_WEIGHT_MODIFIER[build] * weight_mod).round

  { build: build, height_inches: height, weight_lbs: weight }
end
```

Note: `BUILD_HEIGHT_MODIFIER` and `BUILD_WEIGHT_MODIFIER` are defined on the `Descriptions` module itself (not `Human`). They use `Hash.new(1.0)` as default, so missing builds like "Average" return 1.0.

**Step 4: Run tests to verify they pass**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add app/services/character_generator.rb test/services/character_generator_test.rb
git commit -m "Add physical build generation: build, height, weight"
```

---

### Task 3: Appearance — eye color, skin color, hair color, hair texture

**Files:**
- Modify: `app/services/character_generator.rb`
- Test: `test/services/character_generator_test.rb`

**Step 1: Write failing tests**

```ruby
test "generates appearance for human character" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  assert_not_nil character.eye_color
  assert_not_nil character.skin_color
  assert_not_nil character.hair_color
  assert_not_nil character.hair_texture
end

test "non-human ethnicity skips appearance" do
  character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
  assert_nil character.eye_color
  assert_nil character.skin_color
  assert_nil character.hair_color
  assert_nil character.hair_texture
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: New tests FAIL

**Step 3: Implement appearance generation**

Add constant aliases:

```ruby
HUMAN_EYE_COLOR_BY_ETHNICITY = CharacterLegacy::Descriptions::Human::HUMAN_EYE_COLOR_BY_ETHNICITY
HUMAN_SKIN_COLOR_BY_ETHNICITY = CharacterLegacy::Descriptions::Human::HUMAN_SKIN_COLOR_BY_ETHNICITY
HUMAN_HAIR_COLOR_BY_ETHNICITY = CharacterLegacy::Descriptions::Human::HUMAN_HAIR_COLOR_BY_ETHNICITY
HUMAN_HAIR_TEXTURE_BY_ETHNICITY = CharacterLegacy::Descriptions::Human::HUMAN_HAIR_TEXTURE_BY_ETHNICITY
```

Add appearance to `roll_physical`:

```ruby
def roll_physical(stats, sex, ethnicity)
  # ... existing build/height/weight code ...

  {
    build: build,
    height_inches: height,
    weight_lbs: weight,
    eye_color: roll_table(HUMAN_EYE_COLOR_BY_ETHNICITY[ethnicity]),
    skin_color: roll_table(HUMAN_SKIN_COLOR_BY_ETHNICITY[ethnicity]),
    hair_color: roll_table(HUMAN_HAIR_COLOR_BY_ETHNICITY[ethnicity]),
    hair_texture: roll_table(HUMAN_HAIR_TEXTURE_BY_ETHNICITY[ethnicity]),
  }
end
```

**Step 4: Run tests to verify they pass**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add app/services/character_generator.rb test/services/character_generator_test.rb
git commit -m "Add appearance generation: eye/skin/hair color and texture"
```

---

### Task 4: Features — physical features and belongings

**Files:**
- Modify: `app/services/character_generator.rb`
- Test: `test/services/character_generator_test.rb`

**Step 1: Write failing tests**

```ruby
test "generates features for human character" do
  character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
  assert_not_nil character.features
  assert character.features.length > 0
end

test "features resolves gendered slash notation" do
  # Features like "Face - Handsome/Beautiful" should resolve to one word
  20.times do
    character = CharacterGenerator.new(character_class: "Fighter", level: 1).generate
    refute_match %r{/}, character.features, "Features should not contain unresolved slash: #{character.features}"
  end
end

test "non-human ethnicity skips features" do
  character = CharacterGenerator.new(character_class: "Dwarven Vaultguard", level: 1).generate
  assert_nil character.features
end
```

**Step 2: Run tests to verify they fail**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: New tests FAIL

**Step 3: Implement features generation**

Add constant aliases:

```ruby
NEUTRAL_PHYSICAL_FEATURES = CharacterLegacy::Descriptions::PhysicalFeatures::NEUTRAL_PHYSICAL_FEATURES
POSITIVE_PHYSICAL_FEATURES = CharacterLegacy::Descriptions::PhysicalFeatures::POSITIVE_PHYSICAL_FEATURES
NEGATIVE_PHYSICAL_FEATURES = CharacterLegacy::Descriptions::PhysicalFeatures::NEGATIVE_PHYSICAL_FEATURES
BASIC_HUMAN_CATEGORY = CharacterLegacy::Descriptions::Descriptions::BASIC_HUMAN_CATEGORY
BELONGING_TYPE = CharacterLegacy::Descriptions::Belongings::BELONGING_TYPE
```

Add features to `roll_physical` return hash, and add helper methods:

```ruby
def roll_physical(stats, sex, ethnicity)
  # ... existing build/height/weight/appearance code ...

  {
    build: build,
    height_inches: height,
    weight_lbs: weight,
    eye_color: roll_table(HUMAN_EYE_COLOR_BY_ETHNICITY[ethnicity]),
    skin_color: roll_table(HUMAN_SKIN_COLOR_BY_ETHNICITY[ethnicity]),
    hair_color: roll_table(HUMAN_HAIR_COLOR_BY_ETHNICITY[ethnicity]),
    hair_texture: roll_table(HUMAN_HAIR_TEXTURE_BY_ETHNICITY[ethnicity]),
    features: roll_features(stats, sex).join(", "),
  }
end

def roll_features(stats, sex)
  cha_bonus = stat_bonus(stats[:cha])

  features = [roll_table(NEUTRAL_PHYSICAL_FEATURES)]
  if cha_bonus.negative?
    cha_bonus.abs.times { features << roll_table(NEGATIVE_PHYSICAL_FEATURES) }
  elsif cha_bonus.positive?
    cha_bonus.times { features << roll_table(POSITIVE_PHYSICAL_FEATURES) }
  end

  # Handle "Roll Twice" results
  while features.include?("Roll Twice")
    features.delete_at(features.index("Roll Twice"))
    features << roll_table(POSITIVE_PHYSICAL_FEATURES)
    features << roll_table(POSITIVE_PHYSICAL_FEATURES)
  end

  # Resolve gendered slash notation (e.g. "Face - Handsome/Beautiful")
  features.map! do |feature|
    if feature.include?("/")
      type, results = feature.split(" - ")
      result = results.split("/")[male?(sex) ? 0 : 1].strip
      "#{type} - #{result}"
    else
      feature
    end
  end

  # ~35% chance of a belonging
  category = roll_table(BASIC_HUMAN_CATEGORY)
  features << roll_belonging if category == "belongings"

  features
end

def roll_belonging
  belonging_type = BELONGING_TYPE.sample
  alignment_table_name = "#{@alignment.upcase}_#{belonging_type.upcase}"
  any_table_name = "ANY_#{belonging_type.upcase}"

  table = if CharacterLegacy::Descriptions::Belongings.const_defined?(alignment_table_name) && rand < 0.666
             CharacterLegacy::Descriptions::Belongings.const_get(alignment_table_name)
           else
             CharacterLegacy::Descriptions::Belongings.const_get(any_table_name)
           end
  "#{belonging_type.capitalize}: #{roll_table(table)}"
end
```

Note: `roll_belonging` needs access to `@alignment`, so `generate` must set `@alignment` before calling `roll_physical`. Update the `generate` method to store alignment:

```ruby
def generate
  stats = roll_stats
  sex = roll_sex
  ethnicity = roll_ethnicity
  @alignment = roll_table(RANDOM_ALIGNMENT)

  physical = if HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.key?(ethnicity)
               roll_physical(stats, sex, ethnicity)
             else
               {}
             end

  Character.new(
    level: @level,
    character_class: @character_class,
    class_type: @class_type,
    template: roll_die(3).sum,
    alignment: @alignment,
    sex: sex,
    ethnicity: ethnicity,
    name: random_name(ethnicity, sex),
    **stats,
    **physical,
  )
end
```

**Step 4: Run tests to verify they pass**

Run: `bundle exec ruby -Ilib -Itest test/services/character_generator_test.rb`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add app/services/character_generator.rb test/services/character_generator_test.rb
git commit -m "Add features generation with belongings"
```

---

### Task 5: Run full test suite and verify no regressions

**Step 1: Run all tests**

Run: `bundle exec rake test`
Expected: All tests PASS including legacy CharacterLegacy tests

**Step 2: Run rubocop**

Run: `bundle exec rubocop app/services/character_generator.rb test/services/character_generator_test.rb`
Expected: No offenses. Fix any issues found.

**Step 3: Manual smoke test**

Run: `bin/rails runner "puts CharacterGenerator.new(level: 3).generate.attributes.to_yaml"`
Expected: Full character with all fields populated

**Step 4: Commit any fixes**

If rubocop or tests required changes, commit them.
