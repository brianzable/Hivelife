FactoryGirl.define do
  factory :apiary do
    name 'Test Apiary'
    zip_code '60126'
    city 'My City'
    street_address '123 Fake Street'
    state 'IL'

    factory :apiary_with_hives do
      after(:create) do |apiary, evaluator|
        create_list(:hive, 20, apiary: apiary)
      end
    end
  end
end
