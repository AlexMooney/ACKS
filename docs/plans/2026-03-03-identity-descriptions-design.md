# Identity + Descriptions Migration

## Goal

Extend `CharacterGenerator` to populate identity (sex, alignment, ethnicity, name, template) and physical description (build, height, weight, appearance, features) fields on the `Character` AR model. All columns already exist in the schema.

## Design

### Fields populated by `CharacterGenerator#generate`

| Field | Source |
|---|---|
| `template` | `roll_dice("3d6")` |
| `alignment` | Roll on `Descriptions::RANDOM_ALIGNMENT` |
| `sex` | Roll on `ClassTables::SEX_BY_CLASS[@character_class]` |
| `ethnicity` | Random from `Human::HUMAN_HEIGHT_WEIGHT_BY_ETHNICITY.keys`, with Dwarven/Elven override for those classes |
| `name` | `CharacterLegacy::Names#random_name(ethnicity, sex)` |
| `build` | Roll on `Human::HUMAN_BUILD` using `2d6 + 2*STR bonus` |
| `height_inches` | Base (60m/55f) + 2d6 + ethnicity mod, scaled by build |
| `weight_lbs` | Base (110m/90f) + 8d6, scaled by build and ethnicity |
| `eye_color` | Roll on ethnicity eye color table |
| `skin_color` | Roll on ethnicity skin color table |
| `hair_color` | Roll on ethnicity hair color table |
| `hair_texture` | Roll on ethnicity hair texture table |
| `features` | 1 neutral + CHA-bonus-based positive/negative features, joined as comma-separated text |

### Architecture

- `CharacterGenerator` stays as the single service, with private methods for each concern.
- References legacy module constants: `CharacterLegacy::Descriptions::Human`, `CharacterLegacy::Descriptions::PhysicalFeatures`, `CharacterLegacy::Descriptions::Belongings`, `CharacterLegacy::ClassTables`.
- `include CharacterLegacy::Names` in the generator for name instance methods.
- Level 0 characters get `Normal Man` class, no class rolling (matching legacy behavior).
- Stat bonus calculation: `(stat - 10) / 3` floored (matching legacy `Stats#bonus`).
- ~35% chance a character gets a belonging appended to features (from `BASIC_HUMAN_CATEGORY` roll).
- Non-human ethnicities (dwarven, elven) skip physical description generation (matching legacy behavior).

### What doesn't change

- `Character` model stays plain AR with no generation logic.
- Controller and views already handle all these fields.
- Legacy modules in `lib/` stay untouched.

## Testing

- Generated character has all identity/description fields populated (non-nil for humans).
- Ethnicity comes from the valid set.
- Sex respects class-specific ratios (e.g. Bladedancer is always female).
- Dwarven/Elven classes get appropriate ethnicity.
- Height and weight are in reasonable ranges.
- Features string is non-empty.
- Build is one of the valid build values.
