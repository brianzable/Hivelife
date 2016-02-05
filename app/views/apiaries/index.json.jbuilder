json.array!(@apiaries) do |apiary|
  json.id apiary.id
  json.name apiary.name
  json.street_address apiary.street_address
  json.city apiary.city
  json.region apiary.region
  json.postal_code apiary.postal_code
  json.country apiary.country
  json.location "#{apiary.city}, #{apiary.region}"
  json.hive_count apiary.hives.size
  json.hives apiary.hives do |hive|
    json.extract! hive, :id, :name
  end
end
