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
    describe '#show' do
      it 'display the hive name and a list of inspections associated with the hive'
    end

    describe '#edit' do
      it 'displays a form allowing users to edit hive information'
    end

    describe '#new' do
      it 'displays a form allowing users to create a new hive'
    end
  end

  context 'json' do
    before(:each) do
      @http_headers = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    describe '#show' do
      it 'returns a json object with hive information and a list of inspections associated with the hive' do
        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        harvest = FactoryGirl.create(
          :harvest,
          hive: @hive
        )

        get(apiary_hive_path(@apiary, @hive), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(@hive.id)
        expect(parsed_body['name']).to eq(@hive.name)
        expect(parsed_body['apiary_id']).to eq(@hive.apiary_id)
        expect(parsed_body['breed']).to eq(@hive.breed)
        expect(parsed_body['hive_type']).to eq(@hive.hive_type)
        expect(parsed_body['photo_url']).to eq(@hive.photo_url)
        expect(parsed_body['flight_pattern']).to eq(@hive.flight_pattern)
        expect(parsed_body['fine_location_sharing']).to eq(@hive.fine_location_sharing)
        expect(parsed_body['donation_enabled']).to eq(@hive.donation_enabled)
        expect(parsed_body['ventilated']).to eq(@hive.ventilated)
        expect(parsed_body['queen_excluder']).to eq(@hive.queen_excluder)
        expect(parsed_body['entrance_reducer']).to eq(@hive.entrance_reducer)
        expect(parsed_body['entrance_reducer_size']).to eq(@hive.entrance_reducer_size)
        expect(parsed_body['latitude']).to eq(@hive.latitude.to_s)
        expect(parsed_body['longitude']).to eq(@hive.longitude.to_s)
        expect(parsed_body['street_address']).to eq(@hive.street_address)
        expect(parsed_body['city']).to eq(@hive.city)
        expect(parsed_body['state']).to eq(@hive.state)
        expect(parsed_body['zip_code']).to eq(@hive.zip_code)
        expect(parsed_body['orientation']).to eq(@hive.orientation)

        inspections = parsed_body['inspections']
        expect(inspections.count).to be(1)

        inspection_json = inspections.first
        expect(inspection_json['id']).to be(inspection.id)
        expect(inspection_json['inspected_at']).to eq('2014-06-15T08:30:00.000Z')

        harvests = parsed_body['harvests']
        expect(harvests.count).to be(1)

        harvest_json = harvests.first
        expect(harvest_json['id']).to be(harvest.id)
        expect(harvest_json['harvested_at']).to eq('2014-06-15T08:30:00.000Z')
      end

      it 'allows users with read permission to view hive information' do
        @beekeeper.permission = 'Read'
        @beekeeper.save!

        get(apiary_hive_path(@apiary, @hive), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(@hive.id)
      end

      it 'allows users with write permission to view hive information' do
        @beekeeper.permission = 'Write'
        @beekeeper.save!

        get(apiary_hive_path(@apiary, @hive), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(@hive.id)
      end

      it 'allows users with admin permission to view hive information' do
        get(apiary_hive_path(@apiary, @hive), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(@hive.id)
      end

      it 'does not allow unauthorized users to view hive information' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        get(apiary_hive_path(@apiary, @hive), format: :json)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
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
          }
        }.to_json

        post(apiary_hives_path(@apiary), payload, @http_headers)
        expect(response.code).to eq('201')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to_not be_nil
        expect(parsed_body['name']).to eq('A Hive')
        expect(parsed_body['apiary_id']).to eq(@apiary.id)
        expect(parsed_body['breed']).to eq('Italian')
        expect(parsed_body['hive_type']).to eq('Langstroth')
        expect(parsed_body['latitude']).to eq('88.8888')
        expect(parsed_body['longitude']).to eq('88.8888')
        expect(parsed_body['orientation']).to eq('N')
      end

      it 'does not create a hive when hive_type, name, or location fields are missing' do
        payload = {
          hive: {
          }
        }.to_json

        post(apiary_hives_path(@apiary), payload, @http_headers)
        expect(response.code).to eq('422')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['hive_type']).to eq(['is not included in the list'])
        expect(parsed_body['name']).to eq(["Hive name can't be blank"])
        expect(parsed_body['base']).to eq(['Address or location must be set'])
      end

      it 'allows users with write permission to add a hive to an apiary' do
        @beekeeper.permission = 'Write'
        @beekeeper.save!

        payload = {
          hive: {
            hive_type: 'Langstroth',
            breed: 'Italian',
            orientation: 'N',
            name: 'A Hive',
            latitude: 88.8888,
            longitude: 88.8888
          }
        }.to_json

        post(apiary_hives_path(@apiary), payload, @http_headers)
        expect(response.code).to eq('201')
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
          }
        }.to_json

        post(apiary_hives_path(@apiary), payload, @http_headers)
        expect(response.code).to eq('201')
      end

      it 'does not allow users with read permission to add a hive to an apiary' do
        @beekeeper.permission = 'Read'
        @beekeeper.save!

        payload = {
          hive: {
            hive_type: 'Langstroth',
            breed: 'Italian',
            orientation: 'N',
            name: 'A Hive',
            latitude: 88.8888,
            longitude: 88.8888
          }
        }.to_json

        post(apiary_hives_path(@apiary), payload, @http_headers)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end

      it 'does not allow random users to add a hive to an apiary' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        payload = {
          hive: {
            hive_type: 'Langstroth',
            breed: 'Italian',
            orientation: 'N',
            name: 'A Hive',
            latitude: 88.8888,
            longitude: 88.8888
          }
        }.to_json

        post(apiary_hives_path(@apiary), payload, @http_headers)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end
    end

    describe '#update' do
      it 'returns hive information open successful update' do
        payload = {
          hive: {
            hive_type: 'Langstroth',
          }
        }.to_json

        put(apiary_hive_path(@apiary, @hive), payload, @http_headers)
        expect(response.code).to eq('201')

        parsed_body = JSON.parse(response.body)

        expect(parsed_body['id']).to_not be_nil
        expect(parsed_body['name']).to_not be_nil
        expect(parsed_body['apiary_id']).to eq(@apiary.id)
        expect(parsed_body['hive_type']).to eq('Langstroth')
      end

      it 'allows users with write permission to edit hive information' do
        @beekeeper.permission = 'Write'
        @beekeeper.save!

        payload = {
          hive: {
            hive_type: 'Warre',
          }
        }.to_json

        put(apiary_hive_path(@apiary, @hive), payload, @http_headers)
        expect(response.code).to eq('201')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(@hive.id)
      end

      it 'allows users with admin permission to edit hive information' do
        payload = {
          hive: {
            hive_type: 'Warre',
          }
        }.to_json

        put(apiary_hive_path(@apiary, @hive), payload, @http_headers)
        expect(response.code).to eq('201')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(@hive.id)
      end

      it 'does not allow users with read permission to edit hive information' do
        @beekeeper.permission = 'Read'
        @beekeeper.save!

        payload = {
          hive: {
            hive_type: 'Warre',
          }
        }.to_json

        put(apiary_hive_path(@apiary, @hive), payload, @http_headers)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end

      it 'does not allow random users to edit hive information' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        payload = {
          hive: {
            hive_type: 'Langstroth',
          }
        }.to_json

        put(apiary_hive_path(@apiary, @hive), payload, @http_headers)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end
    end

    describe '#destroy' do
      it 'allows admins to delete a hive from an apiary'
      it 'does not allow write users to delete a hive from an apiary'
      it 'does not allow read users to delete a hive from an apiary'
      it 'does not allow random users to delete a hive from an apiary'
      it 'removes all harvests associated with a hive'
      it 'removes all inspection data associated with a hive'
    end
  end
end
