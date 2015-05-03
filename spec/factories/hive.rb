FactoryGirl.define do
  factory :hive do
    sequence :name do |n|
      "Hive #{n}"
    end
    latitude 88.8888888
    longitude 88.8888888
    hive_type 'Langstroth'
  end
end
