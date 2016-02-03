class DropLatitudeLongitude < ActiveRecord::Migration
  def change
    remove_column :hives, :latitude
    remove_column :hives, :longitude
  end
end
