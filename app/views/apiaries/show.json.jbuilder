json.extract! @apiary, :id, :name, :zip_code, :photo_url, :city, :state, :zip_code, :street_address
json.hives do
  json.array!(@apiary.hives) do |hive|
    json.extract! hive, :id, :name
  end
end
