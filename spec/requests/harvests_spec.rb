require 'rails_helper'

describe 'Harvests', type: :request do
  before(:each) do
    @user = create_logged_in_user
    @apiary = FactoryGirl.create(:apiary_with_hives)
    @beekeeper = FactoryGirl.create(
      :beekeeper,
      user: @user,
      apiary: @apiary
    )
    @hive = FactoryGirl.create(
      :hive,
      apiary: @apiary
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
      it 'returns a JSON representation of a harvest' do
        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        get(hive_harvest_path(@hive, harvest), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(harvest.id)
        expect(parsed_body['wax_weight']).to eq(harvest.wax_weight)
        expect(parsed_body['honey_weight']).to eq(harvest.honey_weight)
        expect(parsed_body['weight_units']).to eq(harvest.weight_units)
        expect(parsed_body['harvested_at']).to eq('2014-06-15T08:30:00.000Z')
        expect(parsed_body['notes']).to eq(harvest.notes)
      end

      it 'allows beekeepers with read permissions to view a harvest' do
        @beekeeper.permission = 'Read'
        @beekeeper.save!

        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        get(hive_harvest_path(@hive, harvest), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(harvest.id)
      end

      it 'allows beekeepers with write permissions to view a harvest' do
        @beekeeper.permission = 'Write'
        @beekeeper.save!

        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        get(hive_harvest_path(@hive, harvest), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
      end

      it 'allows beekeepers with admin permissions to view a harvest' do
        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        get(hive_harvest_path(@hive, harvest), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
      end

      it 'does not allow users who are not memebers of the apiary to view a harvest' do
        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        get(hive_harvest_path(@hive, harvest), format: :json)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end
    end

    describe '#create' do
      it 'allows a harvest to be created by a user with admin permissions' do
        payload = {
          harvest: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_harvests_path(@hive), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
        end.to change { Harvest.count }
      end

      it 'allows beekeepers with write permission to create a harvest' do
        @beekeeper.permission = 'Write'
        @beekeeper.save!
        payload = {
          harvest: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_harvests_path(@hive), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
        end.to change { Harvest.count }
      end

      it 'does not allow users with read permissions to create a harvest' do
        @beekeeper.permission = 'Read'
        @beekeeper.save!
        payload = {
          harvest: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_harvests_path(@hive), payload, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change { Harvest.count }
      end

      it 'does not allow users who are not memebers of the apiary to create a harvest' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        payload = {
          harvest: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_harvests_path(@hive), payload, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change { Harvest.count }
      end
    end

    describe '#update' do
      it 'allows an admin to update a harvest' do
        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        payload = {
          harvest: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          put(hive_harvest_path(@hive, harvest), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
          expect(parsed_body['harvested_at']).to eq('2014-06-10T11:00:00.000Z')
        end.to_not change { Harvest.count }
      end

      it 'allows users with write permissions to update a harvest' do
        @beekeeper.permission = 'Write'
        @beekeeper.save

        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        payload = {
          harvest: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          put(hive_harvest_path(@hive, harvest), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
          expect(parsed_body['harvested_at']).to eq('2014-06-10T11:00:00.000Z')
        end.to_not change { Harvest.count }
      end

      it 'does not allow users with read permission to update a harvest' do
        @beekeeper.permission = 'Read'
        @beekeeper.save

        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        payload = {
          harvest: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          put(hive_harvest_path(@hive, harvest), payload, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change { Harvest.count }
      end

      it 'does not allow users who are not members of the apiary to update a harvest' do
        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        payload = {
          harvest: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
        expect do
          put(hive_harvest_path(@hive, harvest), payload, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change { Harvest.count }
      end
    end

    describe '#destroy' do
      it 'allows users with admin permissions to delete a harvest' do
        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        expect do
          delete(hive_harvest_path(@hive, harvest), nil, @http_headers)
          expect(response.code).to eq('200')
        end.to change{ Harvest.count }.by(-1)
      end

      it 'allows users with write permissions to delete a harvest' do
        @beekeeper.permission = 'Write'
        @beekeeper.save

        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        expect do
          delete(hive_harvest_path(@hive, harvest), nil, @http_headers)
          expect(response.code).to eq('200')
        end.to change{ Harvest.count }.by(-1)
      end

      it 'does not allow users with read permissions to delete a harvest' do
        @beekeeper.permission = 'Read'
        @beekeeper.save

        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        expect do
          delete(hive_harvest_path(@hive, harvest), nil, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change{ Harvest.count }
      end

      it 'does not allow users who are not members at the apiary to delete a harvest' do
        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        expect do
          delete(hive_harvest_path(@hive, harvest), nil, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change{ Harvest.count }
      end
    end
  end
end
