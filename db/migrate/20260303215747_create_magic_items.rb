class CreateMagicItems < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_items do |t|
      t.string :name, null: false
      t.string :rarity, null: false
      t.string :item_type, null: false
      t.integer :base_cost, null: false
      t.string :apparent_value, null: false
      t.integer :share, null: false
      t.integer :weighted_share
      t.string :description

      t.timestamps
    end
  end
end
