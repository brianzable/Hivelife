class UpdateInspectionTables < ActiveRecord::Migration
  def change
    change_table :inspections do |t|
      t.remove :health
      t.integer :health
      t.string :pattern
      t.boolean :eggs_sighted
      t.boolean :queen_sighted
      t.boolean :queen_cells_sighted
      t.boolean :swarm_cells_capped
      t.boolean :honey_sighted
      t.boolean :pollen_sighted
      t.boolean :swarm_cells_sighted
      t.boolean :supersedure_cells_sighted

      t.remove :flight_pattern
    end

    change_table :diseases do |t|
      t.string :notes
    end
  end
end
