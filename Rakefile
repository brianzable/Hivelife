# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# Bees::Application.load_tasks
Rails.application.load_tasks

namespace :db do
  desc 'Rebuilds the database and populates sample data'
  task :rebuild do
    Rake::Task['db:drop']
    Rake::Task['db:create']
    Rake::Task['db:schema:load']
    Rake::Task['db:load_sample_data']
  end

  desc 'Populates the database with sample data'
  task :load_sample_data => :environment do
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

    FactoryGirl.create(
      :beekeeper,
      apiary: main_apiary,
      user: user,
      permission: 'Admin'
    )
  end
end
