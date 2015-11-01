FactoryGirl.define do
  factory :harvest do
    honey_weight 60
    wax_weight 2
    harvested_at { Time.now }
    weight_units 'Pounds'
    notes 'Light, clover honey'
  end
end
