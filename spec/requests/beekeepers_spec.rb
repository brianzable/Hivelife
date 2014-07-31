require 'rails_helper'

RSpec.describe 'Beekeepers', type: :request do

  before(:each) do
    @user = create_logged_in_user
    @apiary = FactoryGirl.create(:apiary, user_id: @user.id)
    @beekeeper = FactoryGirl.create(:beekeeper,
                                    user: @user,
                                    apiary: @apiary,
                                    creator: @user.id)
    @beekeeper_json = {
      id: @beekeeper.id,
      permission: @beekeeper.permission,
      apiary_id: @beekeeper.apiary_id,
      user: {
        first_name: @user.first_name,
        last_name: @user.last_name
      }
    }.to_json
  end

  describe '#show' do
    it 'will return a JSON representation of a beekeeper' do
      get beekeeper_path(@beekeeper), format: :json
      expect(response).to be_success
      expect(response.body).to eq(@beekeeper_json)
    end
  end

  describe '#create' do
    it 'will create a new Beekeeper object' do
      data = {
        apiary_id: @apiary.id,
        email: @user.email,
        permission: 'Read'
      }
      puts data.to_json
      post beekeepers_path, data.to_json
      puts response.body

    end

    it 'will return a JSON representation of the new beekeeper object' do

    end
  end

end
=begin
  describe '#index' do
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
=end
