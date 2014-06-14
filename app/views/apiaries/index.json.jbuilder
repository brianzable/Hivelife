json.array!(@apiaries) do |apiary|
  json.extract! apiary, :id
  json.url report_url(apiary, format: :json)
end