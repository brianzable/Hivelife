FactoryGirl.define do
  factory :apiary do
    name 'Test Apiary'
    zip_code '60126'
    city 'My City'
    state 'IL'

    factory :apiary_with_hives do
      transient do
        hives_count 2
      end

      after(:create) do |apiary, evaluator|
        create_list(:hive, evaluator.hives_count, apiary: apiary)
      end
    end
  end
end
