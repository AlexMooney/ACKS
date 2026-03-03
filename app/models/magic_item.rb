class MagicItem < ApplicationRecord
  validates :name, :rarity, :item_type, :base_cost, :apparent_value, :share, presence: true
end
