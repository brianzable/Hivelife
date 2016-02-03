class AddCounterCaches < ActiveRecord::Migration
  def change
    add_column :hives, :inspections_count, :integer
    add_column :hives, :harvests_count, :integer
  end
end
