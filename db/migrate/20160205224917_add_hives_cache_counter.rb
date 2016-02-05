class AddHivesCacheCounter < ActiveRecord::Migration
  def change
    add_column :apiaries, :hives_count, :integer
  end
end
