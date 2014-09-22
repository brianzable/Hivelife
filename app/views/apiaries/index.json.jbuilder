json.array!(@apiaries) do |apiary|
  json.extract! apiary, :id, :name, :photo_url, :city, :state, :zip_code
  json.hives apiary.hives do |hive|
    json.extract! hive, :id, :name
  end
end
