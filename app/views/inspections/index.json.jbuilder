json.array!(@inspections) do |inspection|
  json.id inspection.id
  json.notes inspection.notes
  json.last_edit
  json.inspected_at inspection.inspected_at
end
