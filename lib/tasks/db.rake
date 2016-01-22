namespace :db do
  desc 'Rebuilds the database and adds sample data'
  task rebuild: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:load_sample_data'].invoke
  end

  desc 'Populates the database with sample data'
  task :load_sample_data => :environment do
    other_users = []
    10.times do |index|
      u = FactoryGirl.create(
        :user,
        first_name: 'John',
        last_name: 'Doe',
        photo_url: 'https://dl.dropboxusercontent.com/u/47340/profile.png',
        email: "user#{index}@example.com",
        password: '11111111',
        password_confirmation: '11111111',
      )
      u.activate!

      other_users << u
    end

    user = FactoryGirl.create(
      :user,
      first_name: 'Brian',
      last_name: 'Zable',
      photo_url: 'https://dl.dropboxusercontent.com/u/47340/profile.png',
      email: 'user@example.com',
      password: '11111111',
      password_confirmation: '11111111',
    )
    user.activate!

    main_apiary = FactoryGirl.create(:apiary_with_hives)

    beekeeper = FactoryGirl.create(
      :beekeeper,
      apiary: main_apiary,
      user: user,
      role: Beekeeper::Roles::Admin
    )

    main_apiary.hives.each do |hive|
      3.times do
        hive.inspections << FactoryGirl.build(
          :inspection,
          inspected_at: Time.now - 3.hours,
          notes: 'Everything seems to be well in the hive. Will probably need to add a new honey super next week.',
          inspection_edits: [
            FactoryGirl.build(
              :inspection_edit,
              beekeeper: beekeeper
            )
          ]
        )
        hive.harvests << FactoryGirl.build(
          :harvest,
          harvested_at: Time.now - 3.hours,
          notes: '4 frames, 16 lbs of light, clover honey',
          harvest_edits: [
            FactoryGirl.build(
              :harvest_edit,
              beekeeper: beekeeper
            )
          ]
        )
      end

      hive.save
    end

    other_users.each do |u|
      FactoryGirl.create(
        :beekeeper,
        apiary: main_apiary,
        user: u,
        role: Beekeeper::Roles::Viewer
      )
    end
  end
end
