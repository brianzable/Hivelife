json.array!(@harvests) do |harvest|
  json.extract! harvest, :id, :honey_weight, :wax_weight, :harvested_at, :weight_units, :notes
  json.url harvest_url(harvest, format: :json)
end
