require 'rails_helper'

describe HarvestsController, type: :request do
  let!(:user) { create_logged_in_user }
  let!(:apiary) { FactoryGirl.create(:apiary) }
  let!(:beekeeper) { FactoryGirl.create(:beekeeper,user: user, apiary: apiary) }
  let!(:hive) { FactoryGirl.create(:hive, apiary: apiary) }
  let!(:harvest) { FactoryGirl.create(:harvest, hive: hive) }
  let!(:harvest_edit) { FactoryGirl.create(:harvest_edit, harvest: harvest, beekeeper: beekeeper) }
  let(:headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe '#index' do
    it 'includes the latest edit information with each harvest' do
      3.times do
        existing_harvest = FactoryGirl.create(:harvest, hive: hive)
        FactoryGirl.create(:harvest_edit, harvest: existing_harvest, beekeeper: beekeeper)
      end

      get hive_harvests_path(hive), { format: :json }, headers

      expect(response.status).to eq(200)
      parsed_body = JSON.parse(response.body)
    end

    it 'runs 8 queries' do
      3.times do
        existing_harvest = FactoryGirl.create(:harvest, hive: hive)
        FactoryGirl.create(:harvest_edit, harvest: existing_harvest, beekeeper: beekeeper)
      end

      expect do
        get hive_harvests_path(hive), { format: :json }, headers
      end.to make_database_queries(count: 7..8)

      expect(response.status).to eq(200)
    end
  end

  describe '#show' do
    it 'returns a JSON representation of a harvest' do
      Time.use_zone(user.timezone) do
        harvested_at = Time.new(2016, 7, 31, 13, 30)
        harvest.update_attribute(:harvested_at, harvested_at)
      end

      get hive_harvest_path(hive, harvest), { format: :json }, headers
      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(harvest.id)
      expect(parsed_body['hive_id']).to eq(hive.id)
      expect(parsed_body['apiary_id']).to eq(apiary.id)
      expect(parsed_body['wax_weight']).to eq(harvest.wax_weight)
      expect(parsed_body['wax_weight_units']).to eq(harvest.wax_weight_units)
      expect(parsed_body['honey_weight']).to eq(harvest.honey_weight)
      expect(parsed_body['honey_weight_units']).to eq(harvest.honey_weight_units)
      expect(parsed_body['harvested_at']).to eq('2016-07-31T13:30:00.000-05:00')
      expect(parsed_body['notes']).to eq(harvest.notes)

      last_edit = parsed_body['last_edit']
      expect(last_edit['edited_at']).to_not be_nil
      expect(last_edit['beekeeper_name']).to eq('John Doe')
    end

    it 'runs 8 queries' do
      expect do
        get hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to make_database_queries(count: 7..8)

      expect(response.status).to eq(200)
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
      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    it 'allows a harvest to be created by a user with admin permissions' do
      payload = {
        harvest: {
          harvested_at: Time.now,
          honey_weight: 60,
          honey_weight_units: 'LB',
          wax_weight: 2,
          wax_weight_units: 'OZ',
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
      expect(parsed_body['wax_weight_units']).to eq('OZ')
      expect(parsed_body['honey_weight']).to eq(60)
      expect(parsed_body['honey_weight_units']).to eq('LB')
      expect(parsed_body['harvested_at']).to_not be_nil
      expect(parsed_body['notes']).to eq('Notes about my harvest')
    end

    it 'records the beekeeper who created the harvest' do
      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      expect do
        expect do
          post hive_harvests_path(hive), payload, headers
        end.to change { HarvestEdit.count }.by(1)
      end.to make_database_queries(manipulative: true)

      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      last_edit = parsed_body['last_edit']
      expect(last_edit['edited_at']).to_not be_nil
      expect(last_edit['beekeeper_name']).to eq('John Doe')
    end

    it 'runs 14 queries' do
      payload = {
        harvest: {
          harvested_at: Time.now,
        },
        format: :json
      }

      expect do
        post hive_harvests_path(hive), payload, headers
      end.to make_database_queries(count: 13..14)

      expect(response.status).to eq(201)
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

      expect(response.status).to eq(404)
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

      expect(response.status).to eq(404)
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
          honey_weight_units: 'KG',
          wax_weight: 8,
          wax_weight_units: 'LB',
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
      expect(parsed_body['wax_weight_units']).to eq('LB')
      expect(parsed_body['honey_weight']).to eq(80)
      expect(parsed_body['honey_weight_units']).to eq('KG')
      expect(parsed_body['harvested_at']).to_not be_nil
      expect(parsed_body['notes']).to eq('Notes about my harvest')
    end

    it 'runs 14 queries' do
      payload = {
        harvest: {
          harvested_at: Time.now,
          honey_weight: 80,
          honey_weight_units: 'KG',
          wax_weight: 8,
          wax_weight_units: 'LB',
          notes: 'Notes about my harvest'
        },
        format: :json
      }

      expect do
        put hive_harvest_path(hive, harvest), payload, headers
      end.to make_database_queries(count: 13..14)

      expect(response.status).to eq(201)
    end

    it 'records the beekeeper who made the edit' do
      payload = {
        harvest: {
          notes: 'Some new notes.'
        },
        format: :json
      }

      expect do
        expect do
          put hive_harvest_path(hive, harvest), payload, headers
        end.to change { HarvestEdit.count }.by(1)
      end.to make_database_queries(manipulative: true)

      expect(response.status).to eq(201)

      harvest.reload
      expect(harvest.notes).to eq('Some new notes.')

      parsed_body = JSON.parse(response.body)
      last_edit = parsed_body['last_edit']
      expect(last_edit['edited_at']).to_not be_nil
      expect(last_edit['beekeeper_name']).to eq('John Doe')
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

      expect(response.status).to eq(404)
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

      expect(response.status).to eq(404)
    end
  end

  describe '#destroy' do
    it 'deletes associated HarvestEdits' do
      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to change{ HarvestEdit.count }.by(-1)

      expect(response.status).to eq(200)

      expect { harvest_edit.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'allows users with admin permissions to delete a harvest' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to change{ hive.harvests.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'runs 10 queries' do
      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to make_database_queries(count: 9..11)

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

      expect(response.status).to eq(404)
    end

    it 'does not allow users who are not members at the apiary to delete a harvest' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      expect do
        delete hive_harvest_path(hive, harvest), { format: :json }, headers
      end.to_not change{ hive.harvests.count }

      expect(response.status).to eq(404)
    end
  end
end
