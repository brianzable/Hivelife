json.id @harvest.id
json.hive_id @harvest.hive.id
json.apiary_id @harvest.hive.apiary_id
json.honey_weight @harvest.honey_weight
json.honey_weight_units @harvest.honey_weight_units
json.wax_weight @harvest.wax_weight
json.wax_weight_units @harvest.wax_weight_units
json.harvested_at @harvest.harvested_at
json.notes @harvest.notes

json.last_edit do
  json.edited_at @harvest.last_edit.created_at
  json.beekeeper_name @harvest.last_edit.harvester_name
end
