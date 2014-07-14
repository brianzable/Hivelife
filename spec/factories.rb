FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    email 'john@doe.com'
    password '24ffdbd70e45fd'
  end

  factory :apiary do
    name 'Test Apiary'
    zip_code '60126'
    city 'My City'
    state 'IL'
    zip_code '00000'

    factory :apiary_with_hives do
      ignore do
        hives_count 2
      end

      after(:create) do |apiary, evaluator|
        create_list(:hive, evaluator.hives_count, apiary: apiary, user_id: apiary.user_id)
      end
    end
  end

  factory :beekeeper do
    permission 'Admin'
  end

  factory :hive do
    sequence :name do |n|
      "Hive #{n}"
    end
    latitude 88.8888888
    longitude 88.8888888
    hive_type 'Langstroth'
  end
end
