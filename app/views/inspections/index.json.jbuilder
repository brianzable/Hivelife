json.array!(@inspections) do |inspection|
  json.id inspection.id
  json.notes inspection.notes
  json.inspected_at inspection.inspected_at

  json.last_edit do
    json.edited_at inspection.last_edit.created_at
    json.beekeeper_name inspection.last_edit.inspector_name
  end
end
