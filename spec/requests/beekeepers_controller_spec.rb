require 'rails_helper'

RSpec.describe BeekeepersController, type: :request do

  let!(:user) { create_logged_in_user }
  let!(:apiary) { FactoryGirl.create(:apiary) }

  let!(:admin_beekeeper) do
    FactoryGirl.create(
      :beekeeper,
      apiary: apiary,
      user: user,
      permission: Beekeeper::Roles::Admin
    )
  end

  let!(:beekeeper) do
    FactoryGirl.create(
      :beekeeper,
      user: FactoryGirl.create(:user),
      apiary: apiary,
      permission: Beekeeper::Roles::Viewer
    )
  end

  let(:headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe '#index' do
    it 'returns a list of beekeepers at an apiary' do
      get apiary_beekeepers_path(apiary), { format: :json }, headers

      expect(response.status).to eq(200)
    end

    it 'only lets users who are part of an apiary view the list of beekeepers' do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_apiary = FactoryGirl.create(:apiary)
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: another_apiary
      )

      get apiary_beekeepers_path(another_apiary), { format: :json }, headers

      expect(response.status).to eq(404)
    end

    it 'makes 4 queries' do
      expect do
        get apiary_beekeepers_path(apiary), { format: :json }, headers
      end.to make_database_queries(count: 4)

      expect(response.status).to eq(200)
    end
  end

  describe '#show' do
    it 'returns a JSON representation of a beekeeper' do
      beekeeper_json = {
        id: beekeeper.id,
        permission: beekeeper.permission,
        apiary_id: beekeeper.apiary_id,
        editable: true
      }.to_json

      get apiary_beekeeper_path(apiary, beekeeper), { format: :json }, headers

      expect(response.status).to eq(200)
      expect(response.body).to eq(beekeeper_json)
    end

    it 'makes 4 queries' do
      expect do
        get apiary_beekeeper_path(apiary, beekeeper), { format: :json }, headers
      end.to make_database_queries(count: 4)

      expect(response.status).to eq(200)
    end

    it 'does not allow users to view beekeepers at other apiaries' do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_apiary = FactoryGirl.create(:apiary)
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: another_apiary
      )

      get apiary_beekeeper_path(another_apiary, another_beekeeper), { format: :json }, headers
      expect(response.status).to be(404)
    end
  end

  describe '#create' do
    it 'creates a new Beekeeper in the database' do
      new_user = FactoryGirl.create(:user, email: "new_guy@example.com")
      payload = {
        beekeeper: {
          email: new_user.email,
          permission: Beekeeper::Roles::Viewer
        },
        format: :json
      }

      expect do
        post apiary_beekeepers_path(apiary), payload, headers
      end.to change { Beekeeper.count }.by(1)

      expect(response.status).to eq(201)
    end

    it 'returns a JSON representation of the new beekeeper object' do
      new_user = FactoryGirl.create(:user, email: 'new_guy@example.com')
      payload = {
        beekeeper: {
          email: new_user.email,
          permission: Beekeeper::Roles::Viewer
        },
        format: :json
      }

      post apiary_beekeepers_path(apiary), payload, headers

      expect(response.status).to eq(201)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['id']).to_not be_nil
      expect(parsed_response['apiary_id']).to be(apiary.id)
      expect(parsed_response['permission']).to eq(Beekeeper::Roles::Viewer)
      expect(parsed_response['editable']).to eq(true)
    end

    it 'makes 8 queries' do
      new_user = FactoryGirl.create(:user, email: 'new_guy@example.com')
      payload = {
        beekeeper: {
          email: new_user.email,
          permission: Beekeeper::Roles::Viewer
        },
        format: :json
      }

      expect do
        post apiary_beekeepers_path(apiary), payload, headers
      end.to make_database_queries(count: 7..8)

      expect(response.status).to eq(201)
    end

    it 'will not allow users with write access to create beekeepers' do
      another_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{another_user.authentication_token}" }

      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Inspector
      )

      yet_another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')

      payload = {
        beekeeper: {
          email: yet_another_user.email,
          permission: Beekeeper::Roles::Inspector
        },
        format: :json
      }

      expect do
        post apiary_beekeepers_path(apiary), payload, headers
      end.to_not change { Beekeeper.count }

      expect(response.status).to eq(404)
    end

    it 'will not allow users with read access to create beekeepers' do
      another_user = create_logged_in_user(email: 'another_user@example.com')
      headers = { 'Authorization' => "Token token=#{another_user.authentication_token}" }

      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Inspector
      )

      yet_another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')

      payload = {
        beekeeper: {
          email: yet_another_user.email,
          permission: Beekeeper::Roles::Viewer
        },
        format: :json
      }

      expect do
        post apiary_beekeepers_path(apiary), payload, headers
      end.to_not change { Beekeeper.count }

      expect(response.status).to eq(404)
    end

    it 'will not allow random users to create beekeepers at different apiaries' do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')
      headers = { 'Authorization' => "Token token=#{a_user.authentication_token}" }
      an_apiary = FactoryGirl.create(:apiary)

      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')

      payload = {
        beekeeper: {
          email: another_user.email,
          permission: Beekeeper::Roles::Viewer
        },
        format: :json
      }

      expect do
        post apiary_beekeepers_path(an_apiary), payload, headers
      end.to_not change { Beekeeper.count }

      expect(response.status).to eq(404)
    end
  end

  describe '#update' do
    it 'modifies an existing Beekeeper in the database' do
      payload = {
        beekeeper: {
          permission: Beekeeper::Roles::Inspector
        },
        format: :json
      }

      expect(beekeeper.permission).to eq(Beekeeper::Roles::Viewer)

      put apiary_beekeeper_path(apiary, beekeeper), payload, headers

      beekeeper.reload
      expect(beekeeper.permission).to eq(Beekeeper::Roles::Inspector)

      expect(response.status).to be(200)
    end

    it 'makes 8 queries' do
      payload = {
        beekeeper: {
          permission: Beekeeper::Roles::Inspector
        },
        format: :json
      }

      expect do
        put apiary_beekeeper_path(apiary, beekeeper), payload, headers
      end.to make_database_queries(count: 7..8)

      expect(response.status).to eq(200)
    end

    it 'will not allow users with write access to update beekeepers' do
      write_user = create_logged_in_user(email: 'write_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: write_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Inspector
      )
      headers = { 'Authorization' => "Token token=#{write_user.authentication_token}" }

      another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )

      payload = {
        beekeeper: {
          permission: Beekeeper::Roles::Inspector
        },
        format: :json
      }

      put apiary_beekeeper_path(apiary, another_beekeeper), payload, headers

      another_beekeeper.reload
      expect(another_beekeeper.permission).to eq(Beekeeper::Roles::Viewer)

      expect(response.status).to eq(404)
    end

    it 'will not allow users with read access to update beekeepers' do
      read_user = create_logged_in_user(email: 'read_user@example.com')
      read_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: read_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )
      headers = { 'Authorization' => "Token token=#{read_user.authentication_token}" }

      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )

      payload = {
        beekeeper: {
          permission: Beekeeper::Roles::Inspector
        },
        format: :json
      }

      put apiary_beekeeper_path(apiary, another_beekeeper), payload, headers

      expect(response.status).to eq(404)
      expect(another_beekeeper.reload.permission).to eq(Beekeeper::Roles::Viewer)
    end

    it 'will not allow random users to edit beekeepers at different apiaries' do
      different_apiary = FactoryGirl.create(:apiary)
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')
      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: different_apiary,
        permission: Beekeeper::Roles::Viewer
      )

      payload = {
        beekeeper: {
          permission: Beekeeper::Roles::Admin
        },
        format: :json
      }

      put apiary_beekeeper_path(different_apiary, a_beekeeper), payload, headers

      expect(response.status).to eq(404)
      expect(a_beekeeper.reload.permission).to eq(Beekeeper::Roles::Viewer)
    end

    it 'does not allow admin to demote other admin' do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_admin = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Admin
      )

      payload = {
        beekeeper: {
          permission: Beekeeper::Roles::Viewer
        },
        format: :json
      }

      put apiary_beekeeper_path(apiary, another_admin), payload, headers

      expect(response.status).to eq(404)
      expect(another_admin.reload.permission).to eq(Beekeeper::Roles::Admin)
    end
  end

  describe '#destroy' do
    it 'allows admins to remove beekeepers' do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')
      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )

      expect do
        expect do
          delete apiary_beekeeper_path(apiary, a_beekeeper), nil, headers
        end.to change { Beekeeper.count }.by(-1)
      end.to_not change { User.count }

      expect(response.status).to eq(200)
      expect { a_beekeeper.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'makes 7 queries' do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')
      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )
      expect do
        delete apiary_beekeeper_path(apiary, a_beekeeper), nil, headers
      end.to make_database_queries(count: 6..7)

      expect(response.status).to eq(200)
    end

    it 'does not allow users to remove beekeepers from other apiaries' do
      different_apiary = FactoryGirl.create(:apiary)
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')
      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: different_apiary,
        permission: Beekeeper::Roles::Viewer
      )

      expect do
        delete apiary_beekeeper_path(different_apiary, a_beekeeper), nil, headers
      end.to_not change { Beekeeper.count }

      expect(response.status).to eq(404)
      expect { a_beekeeper.reload }.not_to raise_error
    end

    it 'does not allow write users to remove beekeepers' do
      write_user = FactoryGirl.create(:user, email: 'write_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: write_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Inspector
      )
      headers = { 'Authorization' => "Token token=#{write_user.authentication_token}" }

      read_user = FactoryGirl.create(:user, email: 'read_user@example.com')
      read_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: read_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )

      expect do
        delete apiary_beekeeper_path(apiary, read_beekeeper), nil, headers
      end.to_not change { Beekeeper.count }

      expect(response.status).to eq(404)
      expect { read_beekeeper.reload }.not_to raise_error
    end

    it 'does not allow read users to remove beekeepers' do
      read_user = FactoryGirl.create(:user, email: 'read_user@example.com')
      read_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: read_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )
      headers = { 'Authorization' => "Token token=#{read_user.authentication_token}" }

      another_read_user = FactoryGirl.create(:user, email: 'another_read_user@example.com')
      another_read_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_read_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Viewer
      )

      expect do
        delete apiary_beekeeper_path(apiary, another_read_beekeeper), nil, headers
      end.to_not change { Beekeeper.count }

      expect(response.status).to eq(404)
      expect { another_read_beekeeper.reload }.not_to raise_error
    end

    it 'allows admins to remove themselves' do
      expect do
        delete apiary_beekeeper_path(apiary, admin_beekeeper), nil, headers
      end.to change { Beekeeper.count }.by(-1)

      expect(response.status).to eq(200)
      expect { admin_beekeeper.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not allow admins to remove other admins' do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_admin = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: apiary,
        permission: Beekeeper::Roles::Admin
      )

      expect do
        delete apiary_beekeeper_path(apiary, another_admin), nil, headers
      end.to_not change { Beekeeper.count }

      expect(response.status).to eq(404)
      expect { another_admin.reload }.not_to raise_error
    end
  end
end
