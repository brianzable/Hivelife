require 'rails_helper'

describe "StaticPages", :type => :request do
  describe 'Root URL' do
    it "should have the content 'Welcome to Hivelife!'" do
      visit '/'
      expect(page).to have_content('Welcome to Hivelife!')
    end

    it "should have title 'Hivelife'" do
      visit '/'
      expect(page).to have_title('Hivelife')
    end
  end

  describe 'Data Portal' do
    it "should have title 'Hivelife - Data Portal'" do
      visit '/data'
      expect(page).to have_title('Hivelife | Data Portal')
    end

    it "should have links to all CSV files" do
      visit '/data'
      expect(page).to have_link('Hives', href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/hives.csv')
      expect(page).to have_link('Inspections', href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/inspections.csv')
      expect(page).to have_link('Brood Boxes', href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/brood_boxes.csv')
      expect(page).to have_link('Honey Supers', href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/honey_supers.csv')
      expect(page).to have_link('Diseases', href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/diseases.csv')
      expect(page).to have_link('Harvests', href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/harvests.csv')
    end
  end
end
