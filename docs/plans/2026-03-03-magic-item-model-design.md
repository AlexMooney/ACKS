# MagicItem Model Design

## Goal

Scaffold a `MagicItem` ActiveRecord model and seed the database from the existing magic item CSV files in `lib/magic_items/`. The model is a static catalog of base item templates. Dynamic expansion (spell scrolls, creature warding) and character-item associations are future work.

## Schema

| Column | Type | Notes |
|---|---|---|
| `name` | string | e.g. "Potion of Cure Light Injury", "Sword +1" |
| `rarity` | string | common, uncommon, rare, very_rare, legendary |
| `item_type` | string | potions, rings, scrolls, implements, misc, swords, weapons, armor |
| `base_cost` | integer | GP value |
| `apparent_value` | string | Sometimes numeric, sometimes "as imitated" or "650+" |
| `share` | integer | Probability weight for random selection |
| `weighted_share` | integer | Pre-calculated: base_cost * share |
| `description` | string | Physical description, populated for potions only |

## Seeds

`db/seeds.rb` reads each item CSV (32 files, excludes `frequencies.csv` and `potion_appearances.csv`), derives `rarity` and `item_type` from the filename pattern `{rarity}_{type}.csv`, and creates `MagicItem` records. Uses `find_or_create_by` on `name + rarity + item_type` for idempotency.

## What doesn't change

`TTMagicItems` continues reading CSVs directly. Migrating it to query the DB is a future step.

## Testing

- Seeds create the expected number of records
- Each record has valid rarity and item_type
- No duplicate name+rarity+item_type combinations
