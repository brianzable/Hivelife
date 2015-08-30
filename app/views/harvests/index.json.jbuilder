json.array!(@harvests) do |harvest|
  json.id harvest.id
  json.notes harvest.notes
  json.last_edit 'TODO: Implement this'
  json.harvested_at harvest.harvested_at
end
