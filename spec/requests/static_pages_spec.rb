require 'rails_helper'

describe 'StaticPages', type: :request do

  subject { page }

  describe 'Landing Page' do
    before { visit root_path }

    it "should have the content 'Welcome to Hivelife!'" do
      should have_content('Welcome to Hivelife!')
    end

    it "should have title 'Hivelife'" do
      should have_title('Hivelife')
    end
  end

  describe 'Data Portal' do

    before { visit data_path }

    it "should have title 'Hivelife - Data Portal'" do
      should have_title('Hivelife | Data Portal')
    end

    it 'should have links to all CSV files' do
      should have_link('Hives',
                       href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/hives.csv')
      should have_link('Inspections',
                       href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/inspections.csv')
      should have_link('Brood Boxes',
                       href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/brood_boxes.csv')
      should have_link('Honey Supers',
                       href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/honey_supers.csv')
      should have_link('Diseases',
                       href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/diseases.csv')
      should have_link('Harvests',
                       href: 'https://s3-us-west-2.amazonaws.com/hivelife/dumps/harvests.csv')
    end
  end
end
