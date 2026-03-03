# Magic Item Instance Design

## Problem

MagicItem stores catalog/template data (e.g., "Scroll of Creature Warding", "Spell Scroll (3 levels)", "Sword +1, +2 versus X"). When items are generated, TTMagicItems resolves these templates into concrete names ("Scroll of Warding vs. Dragons"), but the results are transient strings that aren't persisted.

We need a MagicItemInstance model to store resolved magic items with a link back to their template.

## Data Model

### magic_item_instances table

| Column               | Type    | Null | Notes                                    |
|----------------------|---------|------|------------------------------------------|
| magic_item_id        | FK      | no   | Links to template MagicItem              |
| owner_type           | string  | yes  | Polymorphic owner (Character, etc.)      |
| owner_id             | integer | yes  | Polymorphic owner                        |
| override_name        | string  | yes  | Resolved name; falls back to magic_item.name |
| override_description | text    | yes  | Resolved description; falls back to magic_item.description |

### Associations

- MagicItemInstance belongs_to :magic_item
- MagicItemInstance belongs_to :owner, polymorphic: true, optional: true
- MagicItem has_many :magic_item_instances
- Character has_many :magic_item_instances, as: :owner

## Fallback Methods

```ruby
def display_name
  override_name || magic_item.name
end

def display_description
  override_description || magic_item.description
end
```

## MagicItemGenerator Service

Follows the CharacterGenerator pattern:
- Takes rarity quantities (common: N, uncommon: N, etc.)
- Rolls items using MagicItem records and their share/weighted_share weights
- Resolves three template patterns into override_name:
  1. `Spell Scroll (N levels)` -> SpellScroll#roll_details
  2. `Scroll of Creature Warding` -> MagicItems::ScrollCreatureWarding#roll_details
  3. `versus X` -> creature type from ScrollCreatureWarding
- Non-template items get override_name: nil (display_name falls back to magic_item.name)
- Returns unsaved MagicItemInstance records

## Template Patterns (from TTMagicItems L42-54)

These three gsub patterns in TTMagicItems#initialize move to the service:

1. **Spell Scroll**: `/Spell Scroll \((\d+) levels?\)/` -> SpellScroll.new(N).roll_details
2. **Creature Warding**: `"Scroll of Creature Warding"` -> MagicItems::ScrollCreatureWarding.new.roll_details
3. **Versus X**: `" versus X"` -> " versus [creature type]"
