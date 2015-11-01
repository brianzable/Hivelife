require 'rails_helper'

describe HarvestsController, type: :request do

  let!(:user) { create_logged_in_user }
  let!(:apiary) { FactoryGirl.create(:apiary) }
  let!(:beekeeper) { FactoryGirl.create(:beekeeper,user: user, apiary: apiary) }
  let!(:hive) { FactoryGirl.create(:hive, apiary: apiary) }
  let!(:harvest) { FactoryGirl.create(:harvest, hive: hive) }
  let(:headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe '#show' do
    it 'returns a JSON representation of a harvest' do
      get hive_harvest_path(hive, harvest), { format: :json }, headers
      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(harvest.id)
      expect(parsed_body['wax_weight']).to eq(harvest.wax_weight)
      expect(parsed_body['honey_weight']).to eq(harvest.honey_weight)
      expect(parsed_body['weight_units']).to eq(harvest.weight_units)
      expect(parsed_body['harvested_at']).to_not be_nil
      expect(parsed_body['notes']).to eq(harvest.notes)
    end

    it 'allows beekeepers with read permissions to view a harvest' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      get hive_harvest_path(hive, harvest), { format: :json }, headers
      expect(response.status).to eq(200)
    end

    it 'allows beekeepers with write permissions to view a harvest' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      get hive_harvest_path(hive, harvest), { format: :json }, headers
      expect(response.status).to eq(200)
    end

    it 'allows beekeepers with admin permissions to view a harvest' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      get hive_harvest_path(hive, harvest), { format: :json }, headers
      expect(response.status).to eq(200)
    end

    it 'does not allow users who are not memebers of the apiary to view a harvest' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      get hive_harvest_path(hive, harvest), { format: :json }, headers
      expect(response.status).to eq(401)
    end
  end

  describe '#create' do
    it 'allows a harvest to be created by a user with admin permissions' do
      payload = {
        harvest: {
          harvested_at: Time.now,
          honey_weight: 60,
          wax_weight: 2,
          notes: 'Notes about my harvest'
        },
        format: :json
      }

      expect do
        post hive_harvests_path(hive), payload, headers
      end.to change { hive.harvests.count }.by(1)

      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['wax_weight']).to eq(2)
      expect(parsed_body['honey_weight']).to eq(60)
      expect(parsed_body['weight_units']).to be_nil
      expect(parsed_body['harvested_at']).to_not be_nil
      expect(parsed_body['notes']).to eq('Notes about my harvest')
    end

    it 'allows beekeepers with write permission to create a harvest' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      expect do
        post hive_harvests_path(hive), payload, headers
      end.to change { hive.harvests.count }.by(1)

      expect(response.status).to eq(201)
    end

    it 'does not allow users with read permissions to create a harvest' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      expect do
        post hive_harvests_path(hive), payload, headers
      end.to_not change { hive.harvests.count }

      expect(response.status).to eq(401)
    end

    it 'does not allow users who are not memebers of the apiary to create a harvest' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      expect do
        post hive_harvests_path(hive), payload, headers
      end.to_not change { hive.harvests.count }

      expect(response.status).to eq(401)
    end
  end

  describe '#update' do
    it 'allows an admin to update a harvest' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      payload = {
        harvest: {
          harvested_at: Time.now,
          honey_weight: 80,
          wax_weight: 8,
          notes: 'Notes about my harvest'
        },
        format: :json
      }

      expect do
        put hive_harvest_path(hive, harvest), payload, headers
      end.to_not change { hive.harvests.count }

      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['wax_weight']).to eq(8)
      expect(parsed_body['honey_weight']).to eq(80)
      expect(parsed_body['weight_units']).to eq('Pounds')
      expect(parsed_body['harvested_at']).to_not be_nil
      expect(parsed_body['notes']).to eq('Notes about my harvest')
    end

    it 'allows users with write permissions to update a harvest' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      put hive_harvest_path(hive, harvest), payload, headers

      expect(response.status).to eq(201)
    end

    it 'does not allow users with read permission to update a harvest' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      put hive_harvest_path(hive, harvest), payload, headers

      expect(response.status).to eq(401)
    end

    it 'does not allow users who are not members of the apiary to update a harvest' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      put hive_harvest_path(hive, harvest), payload, headers

      expect(response.status).to eq(401)
    end
  end

  describe '#destroy' do
    it 'allows users with admin permissions to delete a harvest' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to change{ hive.harvests.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'allows users with write permissions to delete a harvest' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to change{ hive.harvests.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'does not allow users with read permissions to delete a harvest' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to_not change{ hive.harvests.count }

      expect(response.status).to eq(401)
    end

    it 'does not allow users who are not members at the apiary to delete a harvest' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to_not change{ hive.harvests.count }

      expect(response.status).to eq(401)
    end
  end
end
