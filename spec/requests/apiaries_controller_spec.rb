require 'rails_helper'

RSpec.describe ApiariesController, type: :request do

  let!(:user) { create_logged_in_user }
  let!(:apiary) { FactoryGirl.create(:apiary) }
  let!(:beekeeper) { FactoryGirl.create(:beekeeper, apiary: apiary, user: user) }
  let(:headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe '#index' do
    it "returns a list of the user's apiaries" do
      FactoryGirl.create(:hive, apiary: apiary)

      get apiaries_path, { format: :json }, headers

      apiaries = JSON.parse(response.body)

      expect(apiaries.count).to be(1)

      parsed_apiary = apiaries.first
      expect(parsed_apiary['id']).to eq(apiary.id)
      expect(parsed_apiary['name']).to eq(apiary.name)
      expect(parsed_apiary['photo_url']).to eq(apiary.photo_url)
      expect(parsed_apiary['city']).to eq(apiary.city)
      expect(parsed_apiary['state']).to eq(apiary.state)
      expect(parsed_apiary['zip_code']).to eq(apiary.zip_code)

      parsed_apiary_hives = parsed_apiary['hives']
      expect(parsed_apiary_hives.count).to be(1)
      expect(parsed_apiary_hives[0]['id']).to_not be_nil
      expect(parsed_apiary_hives[0]['name']).to_not be_nil
    end
  end

  describe '#show' do
    it 'allows beekeepers with read permissions to view an apiary' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      get apiary_path(apiary), { format: :json }, headers

      expect(response.status).to eq(200)

      parsed_apiary = JSON.parse(response.body)
      expect(parsed_apiary['id']).to eq(apiary.id)
      expect(parsed_apiary['name']).to eq(apiary.name)
      expect(parsed_apiary['photo_url']).to eq(apiary.photo_url)
      expect(parsed_apiary['city']).to eq(apiary.city)
      expect(parsed_apiary['state']).to eq(apiary.state)
      expect(parsed_apiary['zip_code']).to eq(apiary.zip_code)

      parsed_beekeeper = parsed_apiary['beekeeper']
      expect(parsed_beekeeper['role']).to eq(Beekeeper::Roles::Viewer)
    end

    it 'allows beekeepers with write permissions to view an apiary' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      get apiary_path(apiary), { format: :json }, headers

      expect(response.status).to eq(200)
    end

    it 'allows beekeepers with admin permissions to view an apiary' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      get apiary_path(apiary), { format: :json }, headers

      expect(response.status).to eq(200)
    end

    it 'does not allow users who are not members at an apiary to view it' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      get apiary_path(apiary), { format: :json }, headers
      expect(response.status).to eq(404)

      parsed_body = JSON.parse(response.body)
    end

    it 'returns a 401 when using an invalid authentication token' do
      headers = { 'Authorization' => 'Token token=tokenthatdoesntexist' }

      get apiary_path(apiary), { format: :json }, headers
      expect(response.status).to eq(401)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
    end
  end

  describe '#create' do
    it 'creates and returns a JSON representation of the apiary' do
      payload = {
        apiary: {
          name: 'My Apiary',
          zip_code: '60000',
          city: 'A Town',
          state: 'IL',
          street_address: '123 Fake St'
        },
        format: :json
      }

      expect do
        post apiaries_path, payload, headers
      end.to change { Apiary.count }.by(1)

      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['city']).to eq('A Town')
      expect(parsed_body['state']).to eq('IL')
      expect(parsed_body['street_address']).to eq('123 Fake St')
      expect(parsed_body['zip_code']).to eq('60000')
    end

    it 'creates a beekeeper object making the creator an admin at the new apiary' do
      payload = {
        apiary: {
          name: 'My Apiary',
          zip_code: '60000',
          city: 'A Town',
          state: 'IL',
          street_address: '123 Fake St'
        },
        format: :json
      }

      expect do
        post apiaries_path, payload, headers
      end.to change { Beekeeper.count }.by(1)

      expect(response.status).to eq(201)

      beekeeper = Beekeeper.last
      expect(beekeeper.permission).to eq(Beekeeper::Roles::Admin)
      expect(beekeeper.apiary).to eq(Apiary.last)
    end

    it 'returns an error when trying to create an apiary with no name' do
      payload = {
        apiary: {
          zip_code: '60000'
        },
        format: :json
      }

      expect do
        expect do
          post apiaries_path, payload, headers
        end.to_not change { Beekeeper.count }
      end.to_not change { Apiary.count }

      expect(response.status).to eq(422)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq(["Name can't be blank"])
    end

    it 'returns an error when trying to create an apiary with no zip code' do
      payload = {
        apiary: {
          name: 'My New Apiary'
        },
        format: :json
      }

      expect do
        expect do
          post apiaries_path, payload, headers
        end.to_not change { Beekeeper.count }
      end.to_not change { Apiary.count }

      expect(response.status).to eq(422)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq(["Zip code can't be blank"])
    end

    it 'returns multiple errors when they occur' do
      payload = {
        apiary: {
          city: 'City'
        },
        format: :json
      }

      expect do
        expect do
          post apiaries_path, payload, headers
        end.to_not change { Beekeeper.count }
      end.to_not change { Apiary.count }

      expect(response.status).to eq(422)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response).to eq(["Name can't be blank", "Zip code can't be blank"])
    end
  end

  describe '#update' do
    it 'allows a beekeeper with admin permissions to update an apiary' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      payload = {
        apiary: {
          city: 'Chicago'
        },
        format: :json
      }

      put apiary_path(apiary), payload, headers
      expect(response.status).to eq(201)

      apiary.reload
      expect(apiary.city).to eq('Chicago')
    end

    it 'does not allow users with read permissions to update an apiary' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      payload = {
        apiary: {
          city: 'Chicago'
        },
        format: :json
      }

      put apiary_path(apiary), payload, headers
      expect(response.status).to eq(404)

      apiary.reload
      expect(apiary.city).to eq('My City')
    end

    it 'does not allow users with write permissions to update an apiary' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      payload = {
        apiary: {
          city: 'Chicago'
        },
        format: :json
      }

      put apiary_path(apiary), payload, headers
      expect(response.status).to eq(404)

      apiary.reload
      expect(apiary.city).to eq('My City')
    end

    it 'does not allow administrators of other apiaries to update other apiaries' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      payload = {
        apiary: {
          city: 'Chicago'
        },
        format: :json
      }

      put apiary_path(apiary), payload, headers
      expect(response.status).to eq(404)

      apiary.reload
      expect(apiary.city).to eq('My City')
    end
  end

  describe '#destroy' do
    it 'allows admins at an apiary to delete an apiary' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      expect do
        delete apiary_path(apiary), { format: :json }, headers
      end.to change{ Apiary.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'removes all beekeepers associated with this apiary' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      expect do
        delete apiary_path(apiary), { format: :json }, headers
      end.to change{ Beekeeper.count }.by(-1)

      expect(response.status).to eq(200)
      expect { beekeeper.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'removes all hives associated with this apiary' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      FactoryGirl.create(:hive, apiary: apiary)

      expect do
        delete apiary_path(apiary), { format: :json }, headers
      end.to change{ Hive.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'does not allow users with read permissions to destroy an apiary' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      expect do
        delete apiary_path(apiary), { format: :json }, headers
      end.to_not change{ Apiary.count }

      expect(response.status).to eq(404)
    end

    it 'does not allow users with write permissions to destroy an apiary' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      expect do
        delete apiary_path(apiary), { format: :json }, headers
      end.to_not change{ Apiary.count }

      expect(response.status).to eq(404)
    end

    it 'does not allow users to destroy random apiaries' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      expect do
        delete apiary_path(apiary), { format: :json }, headers
      end.to_not change{ Apiary.count }

      expect(response.status).to eq(404)
    end
  end
end
