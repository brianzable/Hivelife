require 'rails_helper'

describe "StaticPages", :type => :request do
  describe 'Root URL' do
    it "should have the content 'Welcome to Hivelife!'" do
      visit '/'
      expect(page).to have_content('Welcome to Hivelife!')
    end
  end
end
