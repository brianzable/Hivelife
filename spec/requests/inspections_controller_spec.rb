require 'rails_helper'

describe InspectionsController, type: :request do

  let!(:user) { create_logged_in_user }
  let!(:apiary) { FactoryGirl.create(:apiary) }
  let!(:beekeeper) { FactoryGirl.create(:beekeeper,user: user, apiary: apiary) }
  let!(:hive) { FactoryGirl.create(:hive, apiary: apiary) }
  let!(:inspection) { FactoryGirl.create(:inspection, hive: hive) }
  let(:headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe '#show' do
    it 'returns all data associated with an inspection, including diseases' do
      inspected_at = Time.now
      inspection.update_attribute(:inspected_at, inspected_at)
      FactoryGirl.create(:disease, inspection: inspection)

      get hive_inspection_path(hive, inspection), { format: :json }, headers
      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to eq(inspection.id)
      expect(parsed_body['temperature']).to eq(inspection.temperature)
      expect(parsed_body['weather_conditions']).to eq(inspection.weather_conditions)
      expect(parsed_body['weather_notes']).to eq(inspection.weather_notes)
      expect(parsed_body['notes']).to eq(inspection.notes)
      expect(parsed_body['ventilated']).to eq(inspection.ventilated)
      expect(parsed_body['entrance_reducer']).to eq(inspection.entrance_reducer)
      expect(parsed_body['queen_excluder']).to eq(inspection.queen_excluder)
      expect(parsed_body['hive_orientation']).to eq(inspection.hive_orientation)
      expect(parsed_body['health']).to eq(inspection.health)
      expect(parsed_body['hive_temperament']).to eq(inspection.hive_temperament)
      expect(parsed_body['inspected_at']).to_not be_nil
      expect(parsed_body['hive_id']).to eq(hive.id)
      expect(parsed_body['apiary_id']).to eq(apiary.id)
      expect(parsed_body['brood_pattern']).to eq(inspection.brood_pattern)
      expect(parsed_body['eggs_sighted']).to eq(inspection.eggs_sighted)
      expect(parsed_body['queen_sighted']).to eq(inspection.queen_sighted)
      expect(parsed_body['queen_cells_sighted']).to eq(inspection.queen_cells_sighted)
      expect(parsed_body['swarm_cells_capped']).to eq(inspection.swarm_cells_capped)
      expect(parsed_body['honey_sighted']).to eq(inspection.honey_sighted)
      expect(parsed_body['pollen_sighted']).to eq(inspection.pollen_sighted)
      expect(parsed_body['swarm_cells_sighted']).to eq(inspection.swarm_cells_sighted)
      expect(parsed_body['supersedure_cells_sighted']).to eq(inspection.supersedure_cells_sighted)

      disease = parsed_body['diseases'].first
      expect(disease['disease_type']).to eq('Varroa')
      expect(disease['treatment']).to eq('MAQS')
      expect(disease['notes']).to eq('')
    end

    it 'allows beekeepers with read permissions to view an inspection' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      get hive_inspection_path(hive, inspection), { format: :json }, headers
      expect(response.status).to eq(200)
    end

    it 'allows beekeepers with write permissions to view an inspection' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      get hive_inspection_path(hive, inspection), { format: :json }, headers
      expect(response.status).to eq(200)
    end

    it 'allows beekeepers with admin permissions to view an inspection' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      get hive_inspection_path(hive, inspection), { format: :json }, headers
      expect(response.status).to eq(200)
    end

    it 'does not allow users who are not memebers of the apiary to view an inspection' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      get hive_inspection_path(hive, inspection), { format: :json }, headers
      expect(response.status).to eq(404)
    end
  end

  describe '#defaults' do
    it 'returns defaults for the inspection form' do
      get defaults_hive_inspections_path(hive), { format: :json }, headers

      expect(response.status).to eq(200)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['inspection']['apiary_id']).to eq(apiary.id)
    end

    it 'returns defauls for an inspection when no inspections have been made' do
      hive.inspections = []
      hive.save!

      expect do
        get defaults_hive_inspections_path(hive), { format: :json }, headers
      end.to_not change { Inspection.count }

      expect(response.status).to eq(200)
      parsed_body = JSON.parse(response.body)

      expect(parsed_body['inspection']['apiary_id']).to eq(apiary.id)
    end

    it 'allows beekeepers with read permission to view this route' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      get defaults_hive_inspections_path(hive), { format: :json }, headers

      expect(response.status).to eq(200)
    end

    it 'allows beekeepers with write permission to view this route' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      get defaults_hive_inspections_path(hive), { format: :json }, headers

      expect(response.status).to eq(200)
    end

    it 'allows beekeepers with admin permission to view this route' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      get defaults_hive_inspections_path(hive), { format: :json }, headers

      expect(response.status).to eq(200)
    end

    it 'does not allow beekeepers outside the apiary to view this route' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      get defaults_hive_inspections_path(hive), { format: :json }, headers

      expect(response.status).to eq(404)
    end
  end

  describe '#create' do
    it 'allows an inspection to be created without brood boxes, honey supers, or diseases' do
      payload = {
        inspection: {
          temperature: 85,
          weather_conditions: 'Clear',
          weather_notes: 'Very nice day outside.',
          notes: 'Hive is doing great.',
          ventilated: true,
          entrance_reducer: 'Small',
          queen_excluder: false,
          hive_orientation: 'North',
          health: 90,
          inspected_at: Time.now,
          brood_pattern: 'Good',
          eggs_sighted: true,
          queen_sighted: false,
          queen_cells_sighted: false,
          swarm_cells_capped: false,
          swarm_cells_sighted: false,
          supersedure_cells_sighted: false,
          honey_sighted: true,
          pollen_sighted: true
        },
        format: :json
      }

      expect do
        post hive_inspections_path(hive), payload, headers
      end.to change { Inspection.count }

      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['temperature']).to eq(85)
      expect(parsed_body['weather_conditions']).to eq('Clear')
      expect(parsed_body['weather_notes']).to eq('Very nice day outside.')
      expect(parsed_body['notes']).to eq('Hive is doing great.')
      expect(parsed_body['ventilated']).to eq(true)
      expect(parsed_body['entrance_reducer']).to eq('Small')
      expect(parsed_body['queen_excluder']).to eq(false)
      expect(parsed_body['hive_orientation']).to eq('North')
      expect(parsed_body['health']).to eq(90)
      expect(parsed_body['inspected_at']).to_not be_nil
      expect(parsed_body['brood_pattern']).to eq('Good')
      expect(parsed_body['eggs_sighted']).to eq(true)
      expect(parsed_body['queen_sighted']).to eq(false)
      expect(parsed_body['queen_cells_sighted']).to eq(false)
      expect(parsed_body['swarm_cells_capped']).to eq(false)
      expect(parsed_body['honey_sighted']).to eq(true)
      expect(parsed_body['pollen_sighted']).to eq(true)
      expect(parsed_body['swarm_cells_sighted']).to eq(false)
      expect(parsed_body['supersedure_cells_sighted']).to eq(false)
      expect(parsed_body['hive_id']).to eq(hive.id)
    end

    it 'does not allow beekeepers with read permissions to create an inspection' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save!

      payload = {
        inspection: {
          inspected_at: Time.now
        },
        format: :json
      }

      post hive_inspections_path(hive), payload, headers
      expect(response.status).to eq(404)
    end

    it 'allows beekeepers with write permission to create an inspection' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save!

      payload = {
        inspection: {
          inspected_at: Time.now
        },
        format: :json
      }

      post hive_inspections_path(hive), payload, headers
      expect(response.status).to eq(201)
    end

    it 'allows beekeepers with admin permissions to create an inspection' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save!

      payload = {
        inspection: {
          inspected_at: Time.now
        },
        format: :json
      }

      post hive_inspections_path(hive), payload, headers
      expect(response.status).to eq(201)
    end

    it 'does not allow users who are not memebers of the apiary to create an inspection' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      payload = {
        inspection: {
          inspected_at: Time.now
        },
        format: :json
      }

      post hive_inspections_path(hive), payload, headers
      expect(response.status).to eq(404)
    end
  end

  describe '#update' do
    it 'updates an inspection successfully' do
      payload = {
        inspection: {
          notes: 'Some new notes.'
        },
        format: :json
      }

      put hive_inspection_path(hive, inspection), payload, headers

      expect(response.status).to eq(201)

      inspection.reload
      expect(inspection.notes).to eq('Some new notes.')
    end

    it 'allows diseases to be added' do
      payload = {
        inspection: {
          notes: 'Some new notes.',
          diseases_attributes: [
            {
              disease_type: 'Varroa',
              treatment: 'MAQS',
              notes: 'Used one dose'
            }
          ]
        },
        format: :json
      }

      expect do
        put hive_inspection_path(hive, inspection), payload, headers
      end.to change { inspection.diseases.count }

      expect(response.status).to eq(201)

      disease = inspection.diseases.first
      expect(disease.disease_type).to eq('Varroa')
      expect(disease.treatment).to eq('MAQS')
      expect(disease.notes).to eq('Used one dose')
    end

    it 'allows diseases to be updated' do
      disease = FactoryGirl.create(:disease, inspection: inspection)

      payload = {
        inspection: {
          notes: 'Some new notes.',
          diseases_attributes: [
            {
              id: disease.id,
              disease_type: 'Nosema',
              treatment: 'Fumagilin',
              notes: 'Used one small bottle'
            }
          ]
        },
        format: :json
      }

      put hive_inspection_path(hive, inspection), payload, headers

      expect(response.status).to eq(201)

      disease.reload
      expect(disease.inspection).to eq(inspection)
      expect(disease.disease_type).to eq('Nosema')
      expect(disease.treatment).to eq('Fumagilin')
      expect(disease.notes).to eq('Used one small bottle')
    end

    it 'allows diseases to be removed' do
      disease = FactoryGirl.create(:disease, inspection: inspection)

      payload = {
        inspection: {
          notes: 'Some new notes.',
          diseases_attributes: [
            {
              id: disease.id,
              disease_type: 'Nosema',
              treatment: 'Fumagilin',
              notes: 'Used one small bottle',
              _destroy: true
            }
          ]
        },
        format: :json
      }

      expect do
        put hive_inspection_path(hive, inspection), payload, headers
      end.to change { inspection.diseases.count }

      expect(response.status).to eq(201)

      expect { disease.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not allow users with read permission to update an inspection' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save

      payload = {
        inspection: {
          notes: 'Some new notes.'
        },
        format: :json
      }

      put hive_inspection_path(hive, inspection), payload, headers
      expect(response.status).to eq(404)

      inspection.reload
      expect(inspection.notes).to_not eq('Some new notes.')
    end

    it 'allows users with write permissions to update an inspection' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save

      payload = {
        inspection: {
          notes: 'Some new notes.'
        },
        format: :json
      }

      put hive_inspection_path(hive, inspection), payload, headers
      expect(response.status).to eq(201)

      inspection.reload
      expect(inspection.notes).to eq('Some new notes.')
    end

    it 'allows users with admin permissions to update an inspection' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save

      payload = {
        inspection: {
          notes: 'Some new notes.'
        },
        format: :json
      }

      put hive_inspection_path(hive, inspection), payload, headers
      expect(response.status).to eq(201)

      inspection.reload
      expect(inspection.notes).to eq('Some new notes.')
    end

    it 'does not allow users who are not members of the apiary to create an inspection' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      payload = {
        inspection: {
          notes: 'Some new notes.'
        },
        format: :json
      }

      put hive_inspection_path(hive, inspection), payload, headers
      expect(response.status).to eq(404)

      inspection.reload
      expect(inspection.notes).to_not eq('Some new notes.')
    end
  end

  describe '#destroy' do
    it 'allows users with admin permissions to delete an inspection' do
      beekeeper.permission = Beekeeper::Roles::Admin
      beekeeper.save

      expect do
        delete hive_inspection_path(hive, inspection), { format: :json }, headers
      end.to change { Inspection.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'allows users with write permissions to delete an inspection' do
      beekeeper.permission = Beekeeper::Roles::Inspector
      beekeeper.save

      expect do
        delete hive_inspection_path(hive, inspection), { format: :json }, headers
      end.to change { Inspection.count }.by(-1)

      expect(response.status).to eq(200)
    end

    it 'does not allow users with read permissions to delete an inspection' do
      beekeeper.permission = Beekeeper::Roles::Viewer
      beekeeper.save

      expect do
        delete hive_inspection_path(hive, inspection), { format: :json }, headers
      end.to_not change { Inspection.count }

      expect(response.status).to eq(404)
    end

    it 'does not allow users who are not members at the apiary to delete an inspection' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{unauthorized_user.authentication_token}" }

      expect do
        delete hive_inspection_path(hive, inspection), { format: :json }, headers
      end.to_not change { Inspection.count }

      expect(response.status).to eq(404)
    end
  end
end
