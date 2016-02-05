policy = ApiaryPolicy.new(@beekeeper, @apiary)

json.id @apiary.id
json.name @apiary.name
json.street_address @apiary.street_address
json.city @apiary.city
json.region @apiary.region
json.postal_code @apiary.postal_code
json.country @apiary.country

json.beekeeper do
  json.can_edit policy.update?
  json.can_delete policy.destroy?
  json.can_manage_beekeepers @beekeeper.admin?
end

json.hives do
  json.array!(@apiary.hives) do |hive|
    json.id hive.id
    json.name hive.name
    json.inspection_count hive.inspections.size
  end
end
