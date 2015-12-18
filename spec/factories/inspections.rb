FactoryGirl.define do
  factory :inspection do
    weather_conditions 'Clear'
    weather_notes 'Some notes'
    ventilated false
    entrance_reducer false
    queen_excluder false
    hive_orientation 'South'
    hive_temperament 'Calm'
    health true
    brood_pattern 'Good'
    eggs_sighted true
    queen_sighted true
    queen_cells_sighted true
    swarm_cells_capped true
    honey_sighted true
    swarm_cells_sighted true
    supersedure_cells_sighted true
    inspected_at Time.now
  end
end
