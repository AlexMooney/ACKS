# Stat Generation Migration

## Goal

Move ability score generation from `CharacterLegacy::Stats` into an external `CharacterGenerator` service that populates the Rails `Character` AR model.

## Design

**`CharacterGenerator`** (`app/services/character_generator.rb`):
- Takes `character_class:` (and/or `class_type:`) and `level:` as input
- Looks up stat preferences from `CharacterLegacy::ClassTables::STAT_PREFERENCE_BY_CLASS`
- Rolls 6 ability scores using the existing logic:
  - Primary stat: 5d6 keep best 3, minimum 13
  - Two boosted stats: 4d6 keep best 3, minimum 9
  - Remaining stats: 3d6
- Returns an unsaved `Character` record with `str/int/wil/dex/con/cha` populated

**`Character` model** stays a plain AR model with no generation logic.

**References `CharacterLegacy::ClassTables`** for stat preference data (STAT_PREFERENCE_BY_CLASS, STAT_PREFERENCE_BY_CLASS_TYPE) and `Tables` module for dice rolling. These remain in lib/ unchanged.

## Testing

- Generator produces stats in valid ranges (3..18)
- Primary stat for a known class is >= 13
- All 6 stats are populated
