class CreateHarvestEdits < ActiveRecord::Migration
  def change
    create_table :harvest_edits do |t|
      t.integer :harvest_id, null: false, index: true
      t.integer :beekeeper_id, null: false, index: true

      t.timestamps null: false
    end
  end
end
