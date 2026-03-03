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
