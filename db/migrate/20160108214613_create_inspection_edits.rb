class CreateInspectionEdits < ActiveRecord::Migration
  def change
    create_table :inspection_edits do |t|
      t.integer :inspection_id, null: false, index: true
      t.integer :beekeeper_id, null: false, index: true

      t.timestamps null: false
    end
  end
end
