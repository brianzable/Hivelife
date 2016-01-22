json.array!(@beekeepers) do |beekeeper|
  json.id beekeeper.id
  json.name "#{beekeeper.user.first_name} #{beekeeper.user.last_name}"
  json.role beekeeper.role
  json.photo_url beekeeper.user.photo_url
  json.editable BeekeeperPolicy.new(@current_beekeeper, beekeeper).destroy?
end
