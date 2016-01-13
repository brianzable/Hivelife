FactoryGirl.define do
  factory :hive do
    sequence :name do |n|
      "Hive #{n}"
    end
    latitude 41.8369
    longitude -87.623177
    hive_type 'Langstroth'
  end
end
