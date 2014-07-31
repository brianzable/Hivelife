json.extract! @beekeeper, :id, :permission, :apiary_id
json.user do
  json.user_id @beekeeper.user.id
  json.first_name @beekeeper.user.first_name
  json.last_name @beekeeper.user.last_name
end
