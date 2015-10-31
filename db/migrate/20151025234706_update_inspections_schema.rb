class UpdateInspectionsSchema < ActiveRecord::Migration
  def change
    change_table :inspections do |t|
      t.remove :entrance_reducer
      t.rename :entrance_reducer_size, :entrance_reducer
      t.rename :pattern, :brood_pattern
      t.string :hive_temperament
    end
  end
end
