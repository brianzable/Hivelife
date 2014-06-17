require 'rails_helper'

RSpec.describe "Apiaries", :type => :request do
  describe 'Apiaries#index' do
    before(:each) do
      @user = create_logged_in_user
    end

    it "should have title 'Hivelife | Home'" do
      visit '/'
      expect(page).to have_title('Hivelife | Home')
    end
  end
end
