json.extract! @hive, :id, :name, :apiary_id, :breed, :hive_type, :photo_url, :flight_pattern, 
                      :fine_location_sharing, :public, :ventilated, :queen_excluder,
                      :entrance_reducer, :entrance_reducer_size, :latitude, :longitude, :street_address,
                      :city, :state, :zip_code, :orientation
json.inspections do
  json.array!(@hive.inspections) do |inspection|
    json.extract! inspection, :id, :inspected_at
  end
end

json.harvests do
  json.array!(@hive.harvests) do |harvest|
    json.extract! harvest, :id, :harvested_at
  end
end
