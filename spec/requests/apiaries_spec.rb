require 'rails_helper'

RSpec.describe 'Apiaries', type: :request do
  subject { page }

  before(:each) do
    @user = create_logged_in_user
  end

  describe 'Apiaries#index' do
    it "will have title 'Hivelife | Home'" do
      visit '/'
      expect(page).to have_title('Hivelife | Home')
    end

    it 'will link to apiaries#new' do
      visit authenticated_root_path
      expect(page).to have_link('+', href: new_apiary_path)
    end

    it 'will display hive count and apiary city/state' do
      apiary = FactoryGirl.create(:apiary, user_id: @user.id)
      beekeeper = FactoryGirl.create(:beekeeper,
                                      user: @user,
                                      apiary: apiary,
                                      creator: @user.id)
      visit authenticated_root_path
      expect(page).to have_selector('h3', text: '0')
      expect(page).to have_selector('h5', text: 'HIVES')
      expect(page).to have_selector('h3', text: apiary.name)
      expect(page).to have_selector('h5', text: "#{apiary.city}, #{apiary.state}")
    end

    it 'will display hive count (2)' do
      apiary_with_hives = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)
      beekeeper = FactoryGirl.create(:beekeeper,
                                      user: @user,
                                      apiary: apiary_with_hives,
                                      creator: @user.id)
      visit authenticated_root_path
      expect(page).to have_selector('h3', text: '2')
      expect(page).to have_selector('h5', text: 'HIVES')
    end
  end

  describe 'Apiaries#new' do
    it 'will display errors if the name and zip code are blank' do
      visit new_apiary_path
      click_button('Save')
      expect(page).to have_content('Apiary name cannot be blank')
      expect(page).to have_content('Zip code cannot be blank')
    end

    # Check for successful submission

    # Check redirect
  end
end
