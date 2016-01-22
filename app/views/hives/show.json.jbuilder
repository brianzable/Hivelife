json.extract! @hive, :id, :name, :apiary_id, :breed, :hive_type, :latitude, :longitude, :orientation, :exact_location_sharing, :data_sharing,:comments, :source

json.beekeeper do
  json.role @beekeeper.role
end

json.inspections do
  json.array!(@hive.inspections) do |inspection|
    json.id inspection.id
    json.notes inspection.notes
    json.inspected_at inspection.inspected_at
    json.last_edit inspection.updated_at
  end
end

json.harvests do
  json.array!(@hive.harvests) do |harvest|
    json.id harvest.id
    json.notes harvest.notes
    json.harvested_at harvest.harvested_at
    json.last_edit harvest.updated_at
  end
end
