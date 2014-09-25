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
      it 'returns all data associated with an inspection, including brood boxes, honey supers, and diseases'
      it 'allows beekeepers with read permissions to view an inspection'
      it 'allows beekeepers with write permissions to view an inspection'
      it 'allows beekeepers with admin permissions to view an inspection'
      it 'does not allow users who are not memebers of the apiary to view an inspection'
    end

    describe '#create' do
      it 'allows an inspection to be created without brood boxes, honey supers, or diseases'
      it 'allows an inspection to be created with brood boxes'
      it 'allows an inspection to be created with honey supers'
      it 'allows an inspection to be created with diseases'
      it 'does not allow beekeepers with read permissions to create an inspection'
      it 'allows beekeepers with write permission to create an inspection'
      it 'allows beekeepers with admin permissions to create an inspection'
      it 'does not allow users who are not memebers of the apiary to create an inspection'
    end

    describe '#update' do
      it 'updates an inspection successfully'
      it 'allows brood boxes to be updated successfully'
      it 'allows honey supers to be updated successfully'
      it 'allows diseases to be updated successfully'
      it 'does not allow users with read permission to update an inspection'
      it 'allows users with write permissions to update an inspection'
      it 'allows users with admin permissions to update an inspection'
      it 'does not allow users who are not members of the apiary to create an inspection'
    end

    describe '#destroy' do
      it 'allows users with admin permissions to delete an inspection'
      it 'allows users with write permissions to delete an inspection'
      it 'does not allow users with read permissions to delete an inspection'
      it 'removes all brood boxes associated with the inspection'
      it 'removes all honey supers associated with the inspection'
      it 'removes all diseases associated with the inspection'
      it 'does not allow users who are not members at the apiary to delete an inspection'
    end
  end
end
