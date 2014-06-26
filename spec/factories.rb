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
  end

  factory :beekeeper do
    creator { user.id }
    permission 'Admin'
  end
end
