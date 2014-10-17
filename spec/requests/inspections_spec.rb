require 'rails_helper'

describe 'Inspections', type: :request do
  before(:each) do
    @user = create_logged_in_user
    @apiary = FactoryGirl.create(:apiary_with_hives)
    @beekeeper = FactoryGirl.create(
      :beekeeper,
      user: @user,
      apiary: @apiary,
    )
    @hive = FactoryGirl.create(
      :hive,
      apiary: @apiary,
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
      it 'returns all data associated with an inspection, including brood boxes, honey supers, and diseases' do
        inspection = FactoryGirl.create(
          :complete_inspection,
          hive: @hive
        )

        get(hive_inspection_path(@hive, inspection), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(inspection.id)
        expect(parsed_body['temperature']).to eq(inspection.temperature)
        expect(parsed_body['weather_conditions']).to eq(inspection.weather_conditions)
        expect(parsed_body['weather_notes']).to eq(inspection.weather_notes)
        expect(parsed_body['notes']).to eq(inspection.notes)
        expect(parsed_body['ventilated']).to eq(inspection.ventilated)
        expect(parsed_body['entrance_reducer']).to eq(inspection.entrance_reducer)
        expect(parsed_body['entrance_reducer_size']).to eq(inspection.entrance_reducer_size)
        expect(parsed_body['queen_excluder']).to eq(inspection.queen_excluder)
        expect(parsed_body['hive_orientation']).to eq(inspection.hive_orientation)
        expect(parsed_body['flight_pattern']).to eq(inspection.flight_pattern)
        expect(parsed_body['health']).to eq(inspection.health.to_s)
        expect(parsed_body['inspected_at']).to eq('2014-06-15T08:30:00.000Z')
        expect(parsed_body['hive_id']).to eq(inspection.hive_id)

        parsed_brood_boxes = parsed_body['brood_boxes']
        expect(parsed_brood_boxes.count).to be(2)

        brood_box = inspection.brood_boxes.first
        parsed_brood_box = parsed_brood_boxes.first
        expect(parsed_brood_box['pattern']).to eq(brood_box.pattern)
        expect(parsed_brood_box['eggs_sighted']).to eq(brood_box.eggs_sighted)
        expect(parsed_brood_box['queen_sighted']).to eq(brood_box.queen_sighted)
        expect(parsed_brood_box['queen_cells_sighted']).to eq(brood_box.queen_cells_sighted)
        expect(parsed_brood_box['swarm_cells_capped']).to eq(brood_box.swarm_cells_capped)
        expect(parsed_brood_box['honey_sighted']).to eq(brood_box.honey_sighted)
        expect(parsed_brood_box['pollen_sighted']).to eq(brood_box.pollen_sighted)
        expect(parsed_brood_box['swarm_cells_sighted']).to eq(brood_box.swarm_cells_sighted)
        expect(parsed_brood_box['supersedure_cells_sighted']).to eq(brood_box.supersedure_cells_sighted)
        expect(parsed_brood_box['inspection_id']).to eq(brood_box.inspection_id)

        parsed_honey_supers = parsed_body['honey_supers']
        expect(parsed_honey_supers.count).to be(2)

        honey_super = inspection.honey_supers.first
        parsed_honey_super = parsed_honey_supers.first
        expect(parsed_honey_super['inspection_id']).to eq(honey_super.inspection_id)
        expect(parsed_honey_super['full']).to eq(honey_super.full)
        expect(parsed_honey_super['capped']).to eq(honey_super.capped)
        expect(parsed_honey_super['ready_for_harvest']).to eq(honey_super.ready_for_harvest)
      end

      it 'allows beekeepers with read permissions to view an inspection' do
        @beekeeper.permission = 'Read'
        @beekeeper.save!

        inspection = FactoryGirl.create(
          :complete_inspection,
          hive: @hive
        )

        get(hive_inspection_path(@hive, inspection), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(inspection.id)

        parsed_brood_boxes = parsed_body['brood_boxes']
        expect(parsed_brood_boxes.count).to be(2)

        parsed_honey_supers = parsed_body['honey_supers']
        expect(parsed_honey_supers.count).to be(2)
      end

      it 'allows beekeepers with write permissions to view an inspection' do
        @beekeeper.permission = 'Write'
        @beekeeper.save!

        inspection = FactoryGirl.create(
          :complete_inspection,
          hive: @hive
        )

        get(hive_inspection_path(@hive, inspection), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(inspection.id)

        parsed_brood_boxes = parsed_body['brood_boxes']
        expect(parsed_brood_boxes.count).to be(2)

        parsed_honey_supers = parsed_body['honey_supers']
        expect(parsed_honey_supers.count).to be(2)
      end

      it 'allows beekeepers with admin permissions to view an inspection' do
        inspection = FactoryGirl.create(
          :complete_inspection,
          hive: @hive
        )

        get(hive_inspection_path(@hive, inspection), format: :json)
        expect(response.code).to eq('200')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['id']).to eq(inspection.id)

        parsed_brood_boxes = parsed_body['brood_boxes']
        expect(parsed_brood_boxes.count).to be(2)

        parsed_honey_supers = parsed_body['honey_supers']
        expect(parsed_honey_supers.count).to be(2)
      end

      it 'does not allow users who are not memebers of the apiary to view an inspection' do
        inspection = FactoryGirl.create(
          :complete_inspection,
          hive: @hive
        )

        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        get(hive_inspection_path(@hive, inspection), format: :json)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end
    end

    describe '#create' do
      it 'allows an inspection to be created without brood boxes, honey supers, or diseases' do
        payload = {
          inspection: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_inspections_path(@hive), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
          expect(parsed_body['temperature']).to be_nil
          expect(parsed_body['weather_conditions']).to be_nil
          expect(parsed_body['weather_notes']).to be_nil
          expect(parsed_body['notes']).to be_nil
          expect(parsed_body['ventilated']).to be_nil
          expect(parsed_body['entrance_reducer']).to be_nil
          expect(parsed_body['entrance_reducer_size']).to be_nil
          expect(parsed_body['queen_excluder']).to be_nil
          expect(parsed_body['hive_orientation']).to be_nil
          expect(parsed_body['flight_pattern']).to be_nil
          expect(parsed_body['health']).to be_nil
          expect(parsed_body['inspected_at']).to eq('2014-06-15T11:00:00.000Z')
          expect(parsed_body['hive_id']).to eq(@hive.id)

          parsed_brood_boxes = parsed_body['brood_boxes']
          expect(parsed_brood_boxes.count).to be(0)

          parsed_honey_supers = parsed_body['honey_supers']
          expect(parsed_honey_supers.count).to be(0)
        end.to change { Inspection.count }
      end

      it 'allows an inspection to be created with brood boxes' do
        payload = {
          inspection: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM',
            brood_boxes_attributes: [{}, {}]
          }
        }.to_json

        expect do
          post(hive_inspections_path(@hive), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
          expect(parsed_body['temperature']).to be_nil
          expect(parsed_body['weather_conditions']).to be_nil
          expect(parsed_body['weather_notes']).to be_nil
          expect(parsed_body['notes']).to be_nil
          expect(parsed_body['ventilated']).to be_nil
          expect(parsed_body['entrance_reducer']).to be_nil
          expect(parsed_body['entrance_reducer_size']).to be_nil
          expect(parsed_body['queen_excluder']).to be_nil
          expect(parsed_body['hive_orientation']).to be_nil
          expect(parsed_body['flight_pattern']).to be_nil
          expect(parsed_body['health']).to be_nil
          expect(parsed_body['inspected_at']).to eq('2014-06-15T11:00:00.000Z')
          expect(parsed_body['hive_id']).to eq(@hive.id)

          parsed_brood_boxes = parsed_body['brood_boxes']
          expect(parsed_brood_boxes.count).to be(2)

          parsed_honey_supers = parsed_body['honey_supers']
          expect(parsed_honey_supers.count).to be(0)
        end.to change { BroodBox.count }
      end

      it 'allows an inspection to be created with honey supers' do
        payload = {
          inspection: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM',
            honey_supers_attributes: [{}, {}]
          }
        }.to_json

        expect do
          post(hive_inspections_path(@hive), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
          expect(parsed_body['temperature']).to be_nil
          expect(parsed_body['weather_conditions']).to be_nil
          expect(parsed_body['weather_notes']).to be_nil
          expect(parsed_body['notes']).to be_nil
          expect(parsed_body['ventilated']).to be_nil
          expect(parsed_body['entrance_reducer']).to be_nil
          expect(parsed_body['entrance_reducer_size']).to be_nil
          expect(parsed_body['queen_excluder']).to be_nil
          expect(parsed_body['hive_orientation']).to be_nil
          expect(parsed_body['flight_pattern']).to be_nil
          expect(parsed_body['health']).to be_nil
          expect(parsed_body['inspected_at']).to eq('2014-06-15T11:00:00.000Z')
          expect(parsed_body['hive_id']).to eq(@hive.id)

          parsed_brood_boxes = parsed_body['brood_boxes']
          expect(parsed_brood_boxes.count).to be(0)

          parsed_honey_supers = parsed_body['honey_supers']
          expect(parsed_honey_supers.count).to be(2)
        end.to change { HoneySuper.count }
      end

      it 'does not allow beekeepers with read permissions to create an inspection' do
        @beekeeper.permission = 'Read'
        @beekeeper.save!
        payload = {
          inspection: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_inspections_path(@hive), payload, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change { Inspection.count }
      end

      it 'allows beekeepers with write permission to create an inspection' do
        @beekeeper.permission = 'Write'
        @beekeeper.save!
        payload = {
          inspection: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_inspections_path(@hive), payload, @http_headers)
          expect(response.code).to eq('201')
        end.to change { Inspection.count }
      end

      it 'allows beekeepers with admin permissions to create an inspection' do
        @beekeeper.permission = 'Admin'
        @beekeeper.save!
        payload = {
          inspection: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_inspections_path(@hive), payload, @http_headers)
          expect(response.code).to eq('201')
        end.to change { Inspection.count }
      end

      it 'does not allow users who are not memebers of the apiary to create an inspection' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        payload = {
          inspection: {
            day: 15,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          post(hive_inspections_path(@hive), payload, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change { Inspection.count }
      end
    end

    describe '#update' do
      it 'updates an inspection successfully' do
        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        payload = {
          inspection: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        expect do
          put(hive_inspection_path(@hive, inspection), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['id']).to_not be_nil
          expect(parsed_body['temperature']).to be_nil
          expect(parsed_body['weather_conditions']).to_not be_nil
          expect(parsed_body['weather_notes']).to_not be_nil
          expect(parsed_body['notes']).to_not be_nil
          expect(parsed_body['ventilated']).to_not be_nil
          expect(parsed_body['entrance_reducer']).to_not be_nil
          expect(parsed_body['entrance_reducer_size']).to be_nil
          expect(parsed_body['queen_excluder']).to_not be_nil
          expect(parsed_body['hive_orientation']).to_not be_nil
          expect(parsed_body['flight_pattern']).to_not be_nil
          expect(parsed_body['health']).to_not be_nil
          expect(parsed_body['inspected_at']).to eq('2014-06-10T11:00:00.000Z')
          expect(parsed_body['hive_id']).to eq(@hive.id)

          parsed_brood_boxes = parsed_body['brood_boxes']
          expect(parsed_brood_boxes.count).to be(0)

          parsed_honey_supers = parsed_body['honey_supers']
          expect(parsed_honey_supers.count).to be(0)
        end.to_not change { Inspection.count }
      end

      it 'allows brood boxes to be updated successfully' do
        inspection = FactoryGirl.create(
          :inspection_with_brood_boxes,
          hive: @hive
        )

        brood_boxes = inspection.brood_boxes
        brood_box1 = brood_boxes[0]
        brood_box2 = brood_boxes[1]

        expect(brood_box1.queen_sighted).to be(true)
        expect(brood_box2.queen_sighted).to be(true)

        payload = {
          inspection: {
            brood_boxes_attributes: [
              { id: brood_box1.id, queen_sighted: 0 },
              { id: brood_box2.id, queen_sighted: 0 }
            ]
          }
        }.to_json

        expect do
          put(hive_inspection_path(@hive, inspection), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)

          parsed_brood_boxes = parsed_body['brood_boxes']
          expect(parsed_brood_boxes.count).to be(2)

          parsed_brood_boxes = parsed_body['brood_boxes']
          parsed_brood_box1 = parsed_brood_boxes[0]
          expect(parsed_brood_box1['queen_sighted']).to be(false)

          parsed_brood_box2 = parsed_brood_boxes[1]
          expect(parsed_brood_box2['queen_sighted']).to be(false)
        end.to_not change { Inspection.count }
      end

      it 'allows honey supers to be updated successfully' do
        inspection = FactoryGirl.create(
          :inspection_with_honey_supers,
          hive: @hive
        )

        honey_supers = inspection.honey_supers
        honey_super1 = honey_supers[0]
        honey_super2 = honey_supers[1]

        expect(honey_super1.ready_for_harvest).to be(true)
        expect(honey_super2.ready_for_harvest).to be(true)

        payload = {
          inspection: {
            honey_supers_attributes: [
              { id: honey_super1.id, ready_for_harvest: false },
              { id: honey_super2.id, ready_for_harvest: false }
            ]
          }
        }.to_json

        expect do
          put(hive_inspection_path(@hive, inspection), payload, @http_headers)
          expect(response.code).to eq('201')

          parsed_body = JSON.parse(response.body)

          parsed_honey_supers = parsed_body['honey_supers']
          expect(parsed_honey_supers.count).to be(2)

          parsed_honey_super1 = parsed_honey_supers[0]
          expect(parsed_honey_super1['ready_for_harvest']).to be(false)

          parsed_honey_super2 = parsed_honey_supers[1]
          expect(parsed_honey_super2['ready_for_harvest']).to be(false)
        end.to_not change { Inspection.count }
      end

      it 'does not allow users with read permission to update an inspection' do
        @beekeeper.permission = 'Read'
        @beekeeper.save

        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        payload = {
          inspection: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        put(hive_inspection_path(@hive, inspection), payload, @http_headers)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end

      it 'allows users with write permissions to update an inspection' do
        @beekeeper.permission = 'Write'
        @beekeeper.save

        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        payload = {
          inspection: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        put(hive_inspection_path(@hive, inspection), payload, @http_headers)
        expect(response.code).to eq('201')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['inspected_at']).to eq('2014-06-10T11:00:00.000Z')
      end

      it 'allows users with admin permissions to update an inspection' do
        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        payload = {
          inspection: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        put(hive_inspection_path(@hive, inspection), payload, @http_headers)
        expect(response.code).to eq('201')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['inspected_at']).to eq('2014-06-10T11:00:00.000Z')
      end

      it 'does not allow users who are not members of the apiary to create an inspection' do
        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        payload = {
          inspection: {
            day: 10,
            month: 6,
            year: 2014,
            hour: 11,
            minute: 00,
            ampm: 'AM'
          }
        }.to_json

        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        put(hive_inspection_path(@hive, inspection), payload, @http_headers)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end
    end

    describe '#destroy' do
      it 'allows users with admin permissions to delete an inspection' do
        @beekeeper.permission = 'Admin'
        @beekeeper.save

        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        expect do
          delete(hive_inspection_path(@hive, inspection), nil, @http_headers)
          expect(response.code).to eq('200')
        end.to change{ Inspection.count }
      end

      it 'allows users with write permissions to delete an inspection' do
        @beekeeper.permission = 'Write'
        @beekeeper.save

        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        expect do
          delete(hive_inspection_path(@hive, inspection), nil, @http_headers)
          expect(response.code).to eq('200')
        end.to change{ Inspection.count }
      end

      it 'does not allow users with read permissions to delete an inspection' do
        @beekeeper.permission = 'Read'
        @beekeeper.save

        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        expect do
          delete(hive_inspection_path(@hive, inspection), nil, @http_headers)
          expect(response.code).to eq('401')

          parsed_body = JSON.parse(response.body)
          expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
        end.to_not change{ Inspection.count }
      end

      it 'removes all brood boxes associated with the inspection' do
        inspection = FactoryGirl.create(
          :inspection_with_brood_boxes,
          hive: @hive
        )

        expect do
          delete(hive_inspection_path(@hive, inspection), nil, @http_headers)
          expect(response.code).to eq('200')
        end.to change{ BroodBox.count }.by(-2)
      end

      it 'removes all honey supers associated with the inspection' do
        inspection = FactoryGirl.create(
          :inspection_with_honey_supers,
          hive: @hive
        )

        expect do
          delete(hive_inspection_path(@hive, inspection), nil, @http_headers)
          expect(response.code).to eq('200')
        end.to change{ HoneySuper.count }.by(-2)
      end

      it 'does not allow users who are not members at the apiary to delete an inspection' do
        inspection = FactoryGirl.create(
          :inspection,
          hive: @hive
        )

        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        delete(hive_inspection_path(@hive, inspection), nil, @http_headers)
        expect(response.code).to eq('401')

        parsed_body = JSON.parse(response.body)
        expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      end
    end
  end
end
