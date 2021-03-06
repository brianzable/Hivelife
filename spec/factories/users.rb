FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Doe'
    email { "#{SecureRandom.uuid}@example.com" }
    password '11111111'
    password_confirmation '11111111'
    activation_state 'active'
    timezone 'Central Time (US & Canada)'
  end
end
