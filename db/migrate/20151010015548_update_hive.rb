class UpdateHive < ActiveRecord::Migration
  def change
    change_table :hives do |t|
      t.string :comments
      t.string :source

      t.rename :fine_location_sharing, :exact_location_sharing
      t.rename :public, :data_sharing

      t.remove :photo_url
      t.remove :flight_pattern
      t.remove :ventilated
      t.remove :queen_excluder
      t.remove :entrance_reducer
      t.remove :entrance_reducer_size
      t.remove :street_address
      t.remove :city
      t.remove :state
      t.remove :zip_code
    end
  end
end
