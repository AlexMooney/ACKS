# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Random generator tools for the ACKS (Adventurer Conqueror King System) tabletop RPG. The Ruby codebase (`acks.rb`) is an interactive CLI that generates characters, encounters, treasure, magic items, ships, weather, buildings, and more. There is also a legacy Python character generator (`chargen.py`) that is mostly superseded by the Ruby code.

## Migration Goal: CLI → Rails App with SQLite

This project is being incrementally converted from a CLI tool into a Rails web application. The migration approach:

1. **CSV reference data → database seed data.** Tables currently loaded from CSV files (magic item frequencies, encounter tables, treasure types, class data, etc.) should become database-backed models populated via `db/seeds.rb`.
2. **Generated content → persisted records.** Characters, encounters, treasure rolls, ships, and other generated output should be saved to the database rather than just printed to stdout.
3. **Piece-by-piece migration.** Each generator (e.g., treasure, magic items, characters) should be converted independently. The existing `lib/` logic and `Tables` module can be reused inside Rails models/services during the transition.
4. **Keep the `Tables` module and dice rolling.** `roll_table`, `roll_weighted`, and `roll_dice` are used everywhere and should be preserved as a concern or utility module in the Rails app.
5. **Existing tests should keep passing** throughout the migration where possible, adapting from Minitest standalone to Rails test infrastructure.

## Commands

- **Run the app**: `ruby acks.rb` (interactive TTY prompt menu)
- **Run all tests**: `bundle exec rake test` (or just `bundle exec rake`, test is the default task)
- **Run a single test file**: `bundle exec ruby -Ilib -Itest test/treasure_test.rb`
- **Lint**: `bundle exec rubocop`
- **Install dependencies**: `bundle install`
- **Watch for changes**: `bundle exec rake on_update "bundle exec rake test"`

## Architecture

### Autoloading

The project uses **Zeitwerk** for autoloading (`lib/acks.rb`). Files in `lib/` are autoloaded by convention (e.g., `lib/character.rb` → `Character`, `lib/ship/galley_15.rb` → `Ship::Galley15`). The exception is `TTMagicItems` which is manually required because its capitalization doesn't follow Zeitwerk conventions.

### Core Modules

- **`Tables`** (`lib/tables.rb`): Mixed into most classes. Provides `roll_table` (Array or Hash lookup tables), `roll_weighted` (weighted random selection), and `roll_dice` (dice expression parser supporting `NdS`, `NdSk` keep-highest, `NdS!` exploding dice, `N%` percentage, multiplication, and addition).
- **`SpellCheck`** (`lib/spell_check.rb`): Uses `DidYouMean::SpellChecker` to fuzzy-match user input against valid options. Mixed into `Acks` and `Character`.

### Key Classes

- **`Character`** (`lib/character.rb`): Full NPC/character generator with stats, class, level, ethnicity, name, description, combat stats, and magic items. Mixes in many modules from `lib/character/`.
- **`TTMagicItems`** (`lib/tt_magic_items.rb`): Generates magic items by rarity (common/uncommon/rare/very_rare/legendary). Reads frequency and item tables from CSV files in `lib/magic_items/`.
- **`Treasure`** (`lib/treasure.rb`): Rolls treasure by type letter (A-R). Reads from `lib/treasure/treasure_type_table.csv`.
- **`Ship`** (`lib/ship.rb`): Base class for ship types (galleys, small/large/huge ships). Generates crew, cargo, passengers, and captains.
- **`Encounters::WildernessEncounters`** / **`Encounters::NauticalEncounter`**: Generate encounter lists by danger level and terrain.
- **`Terrain`** (`lib/terrain.rb`): Loads monster encounter tables from CSV files in `lib/encounter_tables/`.
- **`Monster::Listing`** (`lib/monster/listing.rb`): Base class for specific monster encounter data (subclasses in `lib/monster/listing/`).
- **`Building`** (`lib/building.rb`): Generates random buildings with occupants.
- **`Henchmen`** (`lib/henchmen.rb`): Generates available henchmen by market class.
- **`Weather`** (`lib/weather.rb`): Weather generation with temperature, precipitation, and wind.

### Data Pattern

Game data lives in CSV files alongside their Ruby consumers (e.g., `lib/magic_items/*.csv`, `lib/encounter_tables/*.csv`, `lib/treasure/treasure_type_table.csv`, `lib/character/class_data.csv`). Tables are loaded at class level and cached.

### Entry Point

`acks.rb` at the root defines the `Acks` class which wires together all generators. Methods ending in `_prompt` use `TTY::Prompt` for interactive input; the non-prompt versions accept arguments directly and are used by tests.

### Testing

Tests use **Minitest** with `minitest/autorun`. Test files are in `test/` mirroring `lib/` structure. Tests call the non-prompt methods on `Acks` or test classes directly, capturing output with `capture_io`. When tests use `TTY::Table`, they stub `$stdout.ioctl` to return 80 for terminal width.
