json.inspection do
  json.apiary_id @inspection.hive.apiary_id
  json.temperature_units @inspection.temperature_units
  json.honey_weight_units @harvest.honey_weight_units
  json.wax_weight_units @harvest.wax_weight_units
end
