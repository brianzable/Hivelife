policy = HivePolicy.new(@beekeeper, @hive)

json.id @hive.id
json.name @hive.name
json.apiary_id @hive.apiary_id
json.hive_type @hive.hive_type
json.latitude @hive.latitude
json.longitude @hive.longitude
json.orientation @hive.orientation
json.exact_location_sharing @hive.exact_location_sharing
json.data_sharing @hive.data_sharing
json.comments @hive.comments
json.breed @hive.breed
json.source @hive.source

json.beekeeper do
  json.can_edit policy.update?
  json.can_delete policy.destroy?
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
