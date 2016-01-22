json.id @beekeeper.id
json.role @beekeeper.role
json.apiary_id @beekeeper.apiary_id
json.editable BeekeeperPolicy.new(@current_beekeeper, @beekeeper).destroy?
