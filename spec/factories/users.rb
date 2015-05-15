FactoryGirl.define do
  factory :user do
    email { "#{SecureRandom.uuid}@example.com" }
    password '11111111'
    password_confirmation '11111111'
  end
end
