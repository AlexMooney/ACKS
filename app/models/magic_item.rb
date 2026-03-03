class MagicItem < ApplicationRecord
  has_many :magic_item_instances, dependent: :restrict_with_error

  validates :name, :rarity, :item_type, :base_cost, :apparent_value, :share, presence: true
end
