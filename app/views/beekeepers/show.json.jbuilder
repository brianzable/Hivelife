json.id @beekeeper.id
json.permission @beekeeper.permission
json.apiary_id @beekeeper.apiary_id
json.editable BeekeeperPolicy.new(@current_beekeeper, @beekeeper).destroy?
