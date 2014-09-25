require 'rails_helper'

describe 'Hives', type: :request do
  before(:each) do
    @user = create_logged_in_user
    @apiary = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)
    @beekeeper = FactoryGirl.create(
      :beekeeper,
      user: @user,
      apiary: @apiary,
      creator: @user.id
    )
    @hive = FactoryGirl.create(
      :hive,
      apiary: @apiary,
      user: @user
    )
  end

  context 'html' do
  end

  context 'json' do
    before(:each) do
      @http_headers = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    describe '#show' do
    end

    describe '#create' do
    end

    describe '#update' do
    end

    describe '#destroy' do
    end
  end
end
