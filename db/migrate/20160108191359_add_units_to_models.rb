class AddUnitsToModels < ActiveRecord::Migration
  def change
    add_column :inspections, :temperature_units, :string, :default => nil
    add_column :harvests, :honey_weight_units, :string, :default => nil
    add_column :harvests, :wax_weight_units, :string, :default => nil
  end
end
