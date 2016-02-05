policy = InspectionPolicy.new(@beekeeper, @inspection)

json.id @inspection.id
json.hive_id @hive.id
json.apiary_id @hive.apiary_id
json.temperature @inspection.temperature
json.temperature_units @inspection.temperature_units
json.weather_conditions @inspection.weather_conditions
json.weather_notes @inspection.weather_notes
json.ventilated @inspection.ventilated
json.entrance_reducer @inspection.entrance_reducer
json.queen_excluder @inspection.queen_excluder
json.hive_orientation @inspection.hive_orientation
json.health @inspection.health
json.hive_temperament @inspection.hive_temperament
json.inspected_at @inspection.inspected_at
json.notes @inspection.notes
json.brood_pattern @inspection.brood_pattern
json.eggs_sighted @inspection.eggs_sighted
json.queen_sighted @inspection.queen_sighted
json.queen_cells_sighted @inspection.queen_cells_sighted
json.swarm_cells_sighted @inspection.swarm_cells_sighted
json.swarm_cells_capped @inspection.swarm_cells_capped
json.honey_sighted @inspection.honey_sighted
json.supersedure_cells_sighted @inspection.supersedure_cells_sighted
json.pollen_sighted @inspection.pollen_sighted

json.beekeeper do
  json.can_delete policy.destroy?
  json.can_edit policy.update?
end

json.last_edit do
  json.edited_at @inspection.last_edit.created_at
  json.beekeeper_name @inspection.last_edit.inspector_name
end

json.diseases do
  json.array!(@inspection.diseases) do |disease|
    json.extract! disease, :id, :disease_type, :treatment, :notes
  end
end
