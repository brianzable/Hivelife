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
        user_id: @user.id,
        first_name: @user.first_name,
        last_name: @user.last_name
      }
    }.to_json

    @http_headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  describe '#show' do
    it 'returns a JSON representation of a beekeeper' do
      get apiary_beekeeper_path(@apiary, @beekeeper), format: :json
      expect(response).to be_success
      expect(response.body).to eq(@beekeeper_json)
    end
  end

  describe '#create' do
    it 'creates a new Beekeeper in the database' do
      new_user = FactoryGirl.create(:user, email: "new_guy@example.com")
      data = {
        beekeeper: {
          email: new_user.email,
          permission: 'Read'
        }
      }
      original_beek_count = Beekeeper.count

      post(apiary_beekeepers_path(@apiary), data.to_json, @http_headers)

      expect(response).to be_success
      expect(Beekeeper.count).to be(original_beek_count + 1)
    end

    it 'returns a JSON representation of the new beekeeper object' do
      new_user = FactoryGirl.create(:user, email: "new_guy@example.com")
      data = {
        beekeeper: {
          email: new_user.email,
          permission: 'Read'
        }
      }

      post(apiary_beekeepers_path(@apiary), data.to_json, @http_headers)

      expect(response).to be_success

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["id"]).to_not be_nil
      expect(parsed_response["apiary_id"]).to be(@apiary.id)
      expect(parsed_response["permission"]).to eq("Read")
      expect(parsed_response["user"]["user_id"]).to be(new_user.id)
      expect(parsed_response["user"]["first_name"]).to eq(new_user.first_name)
      expect(parsed_response["user"]["last_name"]).to eq(new_user.last_name)
    end
  end
end
