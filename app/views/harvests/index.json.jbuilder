json.array!(@harvests) do |harvest|
  json.id harvest.id
  json.notes harvest.notes
  json.harvested_at harvest.harvested_at

  json.last_edit do
    json.edited_at harvest.last_edit.created_at
    json.beekeeper_name harvest.last_edit.harvester_name
  end
end
