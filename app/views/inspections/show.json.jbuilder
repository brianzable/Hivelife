json.extract! @inspection, :id, :weather_conditions, :weather_notes, :ventilated, :entrance_reducer,
                           :queen_excluder, :hive_orientation, :health, :hive_temperament,
                           :inspected_at, :hive_id, :notes, :brood_pattern, :eggs_sighted, :queen_sighted,
                           :queen_cells_sighted, :swarm_cells_sighted, :swarm_cells_capped, :honey_sighted,
                           :supersedure_cells_sighted, :temperature, :pollen_sighted, :hive_id

json.diseases do
  json.array!(@inspection.diseases) do |disease|
    json.extract! disease, :id, :disease_type, :treatment, :notes
  end
end
