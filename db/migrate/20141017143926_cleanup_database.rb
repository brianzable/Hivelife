class CleanupDatabase < ActiveRecord::Migration
  def change
    change_table :apiaries do |t|
      t.remove :user_id
    end

    change_table :beekeepers do |t|
      t.remove :creator
    end

    change_table :brood_boxes do |t|
      t.rename :supercedure_cell_sighted, :supersedure_cells_sighted
      t.rename :swarm_cell_sighted, :swarm_cells_sighted
    end

    change_table :harvests do |t|
      t.remove :user_id
    end

    change_table :hives do |t|
      t.remove :user_id
      t.rename :donation_enabled, :public
    end

    change_table :inspections do |t|
      t.remove :user_id
    end
  end
end
