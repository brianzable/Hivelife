json.array!(@hives) do |hive|
  json.extract! hive, :id
  json.url hive_url(hive, format: :json)
end