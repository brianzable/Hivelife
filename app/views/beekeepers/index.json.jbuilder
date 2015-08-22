json.array!(@beekeepers) do |beekeeper|
  json.name "#{beekeeper.user.first_name} #{beekeeper.user.last_name}"
  json.role beekeeper.permission
  json.photo_url beekeeper.user.photo_url
end
