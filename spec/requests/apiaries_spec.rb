require 'rails_helper'

RSpec.describe 'Apiaries', type: :request do
  subject { page }

  before(:each) do
    @user = create_logged_in_user
  end

  describe 'Apiaries#index' do

    it "should have title 'Hivelife | Home'" do
      visit root_path
      should have_title('Hivelife | Home')
    end

    it 'should have the create apiary button' do
      visit root_path
      should have_link('+', href: new_apiary_path)
    end

    it 'should display an apiary name' do
      apiary = FactoryGirl.create(:apiary)
      beekeeper = FactoryGirl.create(:beekeeper, user: @user, apiary: apiary)

      visit root_path

      should have_content('Test Apiary')
      should have_content('0 HIVES')
    end
  end
end
