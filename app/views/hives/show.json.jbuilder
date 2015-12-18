json.extract! @hive, :id, :name, :apiary_id, :breed, :hive_type, :latitude, :longitude, :orientation, :exact_location_sharing, :data_sharing,:comments, :source

json.beekeeper do
  json.role @beekeeper.permission
end

json.inspections do
  json.array!(@hive.inspections) do |inspection|
    json.extract! inspection, :id, :notes, :inspected_at
  end
end

json.harvests do
  json.array!(@hive.harvests) do |harvest|
    json.extract! harvest, :id, :notes, :harvested_at
  end
end
