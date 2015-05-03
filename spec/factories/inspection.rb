FactoryGirl.define do
  factory :inspection do
    weather_conditions 'Clear'
    weather_notes 'Some notes'
    ventilated 0
    entrance_reducer 0
    queen_excluder 0
    hive_orientation 'S'
    flight_pattern 'Flying south'
    health 1
    month 6
    day 15
    year 2014
    hour 8
    minute 30
    ampm 'AM'
    notes 'Other notes'
    transient do
      brood_box_count 2
      honey_super_count 2
    end

    factory :inspection_with_brood_boxes do
      after(:create) do |inspection, evaluator|
        create_list(:brood_box, evaluator.brood_box_count, inspection: inspection)
      end
    end

    factory :inspection_with_honey_supers do
      after(:create) do |inspection, evaluator|
        create_list(:honey_super, evaluator.honey_super_count, inspection: inspection)
      end
    end

    factory :complete_inspection do
      after(:create) do |inspection, evaluator|
        create_list(:honey_super, evaluator.honey_super_count, inspection: inspection)
        create_list(:brood_box, evaluator.brood_box_count, inspection: inspection)
      end
    end
  end

  factory :brood_box do
    pattern 'Good'
    eggs_sighted 1
    queen_sighted 1
    queen_cells_sighted 1
    swarm_cells_capped 1
    honey_sighted 1
    swarm_cells_sighted 1
    supersedure_cells_sighted 1
  end

  factory :honey_super do
    full 1
    capped 1
    ready_for_harvest true
  end
end
