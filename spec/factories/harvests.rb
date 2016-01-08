FactoryGirl.define do
  factory :harvest do
    honey_weight 60
    honey_weight_units 'LB'
    wax_weight 2
    wax_weight_units 'OZ'
    harvested_at { Time.now }
    notes 'Light, clover honey'
  end
end
