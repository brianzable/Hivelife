require 'rails_helper'

describe HivesController, type: :request do

  let!(:user) { create_logged_in_user }
  let!(:apiary) { FactoryGirl.create(:apiary_with_hives) }
  let!(:beekeeper) { FactoryGirl.create(:beekeeper,user: user, apiary: apiary) }
  let!(:hive) { FactoryGirl.create(:hive, apiary: apiary) }
  let(:headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe '#show' do
    it 'returns a json object with hive information and a list of inspections associated with the hive' do
      inspection = FactoryGirl.create(:inspection, hive: hive)
      harvest = FactoryGirl.create(:harvest, hive: hive)

      get apiary_hive_path(apiary, hive), { format: :json }, headers
      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(hive.id)
      expect(parsed_body['name']).to eq(hive.name)
      expect(parsed_body['apiary_id']).to eq(hive.apiary_id)
      expect(parsed_body['breed']).to eq(hive.breed)
      expect(parsed_body['hive_type']).to eq(hive.hive_type)
      expect(parsed_body['exact_location_sharing']).to eq(hive.exact_location_sharing)
      expect(parsed_body['data_sharing']).to eq(hive.data_sharing)
      expect(parsed_body['latitude']).to eq(hive.latitude.to_s)
      expect(parsed_body['longitude']).to eq(hive.longitude.to_s)
      expect(parsed_body['orientation']).to eq(hive.orientation)

      beekeeper = parsed_body['beekeeper']
      expect(beekeeper['role']).to eq(Beekeeper::Roles::Admin)

      inspections = parsed_body['inspections']
      expect(inspections.count).to be(1)

      inspection_json = inspections.first
      expect(inspection_json['id']).to be(inspection.id)

      harvests = parsed_body['harvests']
      expect(harvests.count).to be(1)

      harvest_json = harvests.first
      expect(harvest_json['id']).to be(harvest.id)
    end

    it 'allows users with read permission to view hive information' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      get apiary_hive_path(apiary, hive), { format: :json }, headers
      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(hive.id)
    end

    it 'allows users with write permission to view hive information' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      get apiary_hive_path(apiary, hive), { format: :json }, headers
      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(hive.id)
    end

    it 'allows users with admin permission to view hive information' do
      get apiary_hive_path(apiary, hive), { format: :json }, headers
      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(hive.id)
    end

    it 'does not allow unauthorized users to view hive information' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      get apiary_hive_path(apiary, hive), { format: :json }, headers
      expect(response.status).to eq(404)

      parsed_body = JSON.parse(response.body)
    end
  end

  describe '#create' do
    it 'displays hive information after a hive is created' do
      payload = {
        hive: {
          hive_type: 'Langstroth',
          breed: 'Italian',
          orientation: 'N',
          name: 'A Hive',
          latitude: 88.8888,
          longitude: 88.8888
        },
        format: :json
      }

      post apiary_hives_path(apiary), payload, headers
      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['name']).to eq('A Hive')
      expect(parsed_body['apiary_id']).to eq(apiary.id)
      expect(parsed_body['breed']).to eq('Italian')
      expect(parsed_body['hive_type']).to eq('Langstroth')
      expect(parsed_body['latitude']).to eq('88.8888')
      expect(parsed_body['longitude']).to eq('88.8888')
      expect(parsed_body['orientation']).to eq('N')
    end

    it 'renders full error messages when validation errors are present' do
      payload = {
        hive: {
          latitude: 88.8888,
          longitude: 88.8888
        },
        format: :json
      }

      expect do
        post apiary_hives_path(apiary), payload, headers
      end.to_not change { Hive.count }

      expect(response.status).to eq(422)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq(["Name can't be blank"])
    end

    it 'allows users with write permission to add a hive to an apiary' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      payload = {
        hive: {
          hive_type: 'Langstroth',
          breed: 'Italian',
          orientation: 'N',
          name: 'A Hive',
          latitude: 88.8888,
          longitude: 88.8888
        },
        format: :json
      }

      post apiary_hives_path(apiary), payload, headers
      expect(response.status).to eq(201)
    end

    it 'allows users with admin permission to add a hive to the apiary' do
      payload = {
        hive: {
          hive_type: 'Langstroth',
          breed: 'Italian',
          orientation: 'N',
          name: 'A Hive',
          latitude: 88.8888,
          longitude: 88.8888
        },
        format: :json
      }

      post apiary_hives_path(apiary), payload, headers
      expect(response.status).to eq(201)
    end

    it 'does not allow users with read permission to add a hive to an apiary' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      payload = {
        hive: {
          hive_type: 'Langstroth',
          breed: 'Italian',
          orientation: 'N',
          name: 'A Hive',
          latitude: 88.8888,
          longitude: 88.8888
        },
        format: :json
      }

      post apiary_hives_path(apiary), payload, headers
      expect(response.status).to eq(404)
    end

    it 'does not allow random users to add a hive to an apiary' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      payload = {
        hive: {
          hive_type: 'Langstroth',
          breed: 'Italian',
          orientation: 'N',
          name: 'A Hive',
          latitude: 88.8888,
          longitude: 88.8888
        },
        format: :json
      }

      post apiary_hives_path(apiary), payload, headers
      expect(response.status).to eq(404)
    end
  end

  describe '#update' do
    it 'returns hive information open successful update' do
      payload = {
        hive: {
          hive_type: 'Langstroth',
        },
        format: :json
      }

      put apiary_hive_path(apiary, hive), payload, headers
      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['name']).to_not be_nil
      expect(parsed_body['apiary_id']).to eq(apiary.id)
      expect(parsed_body['hive_type']).to eq('Langstroth')
    end

    it 'allows users with write permission to edit hive information' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      payload = {
        hive: {
          hive_type: 'Langstroth',
        },
        format: :json
      }

      put apiary_hive_path(apiary, hive), payload, headers
      expect(response.status).to eq(201)
    end

    it 'allows users with admin permission to edit hive information' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      payload = {
        hive: {
          hive_type: 'Langstroth',
        },
        format: :json
      }

      put apiary_hive_path(apiary, hive), payload, headers
      expect(response.status).to eq(201)
    end

    it 'does not allow users with read permission to edit hive information' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      payload = {
        hive: {
          hive_type: 'Langstroth',
        },
        format: :json
      }

      put apiary_hive_path(apiary, hive), payload, headers
      expect(response.status).to eq(404)
    end

    it 'does not allow random users to edit hive information' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      payload = {
        hive: {
          hive_type: 'Langstroth',
        },
        format: :json
      }

      put apiary_hive_path(apiary, hive), payload, headers
      expect(response.status).to eq(404)
    end
  end

  describe '#destroy' do
    it 'allows admins to delete a hive from an apiary' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      expect do
        delete apiary_hive_path(apiary, hive), { format: :json }, headers
      end.to change { apiary.hives.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'does not allow write users to delete a hive from an apiary' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      expect do
        delete apiary_hive_path(apiary, hive), { format: :json }, headers
      end.to_not change { apiary.hives.count }

      expect(response.status).to eq(404)
    end

    it 'does not allow read users to delete a hive from an apiary' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      expect do
        delete apiary_hive_path(apiary, hive), { format: :json }, headers
      end.to_not change { apiary.hives.count }

      expect(response.status).to eq(404)
    end

    it 'does not allow random users to delete a hive from an apiary' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      expect do
        delete apiary_hive_path(apiary, hive), { format: :json }, headers
      end.to_not change { apiary.hives.count }

      expect(response.status).to eq(404)
    end
  end
end
