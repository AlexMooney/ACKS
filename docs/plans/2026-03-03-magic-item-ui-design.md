# Magic Item Generator UI Design

## Goal

Add a web UI for randomly generating magic items, mirroring the existing CLI flow. Single page with a form and results, no persistence.

## Route

```ruby
resources :magic_items, only: [] do
  collection do
    get :generate
  end
end
```

Single page at `/magic_items/generate`. Form submits via GET so results are bookmarkable.

## Page Flow

1. User visits `/magic_items/generate`
2. Form with 5 number fields (common, uncommon, rare, very_rare, legendary), defaulting to 0
3. Hits "Generate"
4. Page reloads with same form (quantities preserved) plus results below, grouped by rarity

## Controller

`MagicItemsController#generate` — if quantity params present, calls `TTMagicItems.new(...)` and passes `@magic_items` to the view. Otherwise renders empty form.

## View

Uses existing paper/fieldset styling. Results as a list grouped by rarity. Form fields use `.field-row` with `.field-narrow`.

## Home Page

Add link: "Generate Magic Items" → `generate_magic_items_path`

## Testing

- GET generate with no params renders form
- GET generate with quantities returns results with item names
