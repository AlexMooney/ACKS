class CreateMagicItemInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_item_instances do |t|
      t.references :magic_item, null: false, foreign_key: true
      t.references :owner, polymorphic: true, null: true
      t.string :override_name
      t.text :override_description

      t.timestamps
    end
  end
end
