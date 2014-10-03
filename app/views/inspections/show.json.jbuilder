json.extract! @inspection, :id, :weather_conditions, :weather_notes, :ventilated, :entrance_reducer,
                           :entrance_reducer_size, :queen_excluder, :hive_orientation, :flight_pattern,
                           :health, :inspected_at, :hive_id, :notes

json.brood_boxes do
  json.array!(@inspection.brood_boxes) do |brood_box|
    json.extract! brood_box, :eggs_sighted, :queen_sighted, :queen_cells_sighted, :swarm_cells_capped,
                             :honey_sighted, :pollen_sighted, :swarm_cell_sighted, :supercedure_cell_sighted,
                             :inspection_id, :pattern 
  end
end

json.honey_supers do
  json.array!(@inspection.honey_supers) do |honey_super|
    json.extract! honey_super, :full, :capped, :ready_for_harvest, :inspection_id
  end
end
