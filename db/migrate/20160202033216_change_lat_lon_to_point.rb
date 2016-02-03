class ChangeLatLonToPoint < ActiveRecord::Migration
  def change
    change_table :hives do |t|
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist
    end
  end
end
