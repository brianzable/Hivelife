json.array!(@hives) do |hive|
  json.id hive.id
  json.name hive.name
end
