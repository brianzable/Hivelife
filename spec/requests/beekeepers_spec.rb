require 'rails_helper'

RSpec.describe 'Beekeepers', type: :request do

  before(:each) do
    @user = create_logged_in_user
    @apiary = FactoryGirl.create(:apiary, user_id: @user.id)
    @beekeeper = FactoryGirl.create(:beekeeper,
                                    user: @user,
                                    apiary: @apiary,
                                    creator: @user.id)

    @http_headers = {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  describe '#show' do
    it 'returns a JSON representation of a beekeeper' do
      get apiary_beekeeper_path(@apiary, @beekeeper), format: :json

      beekeeper_json = {
        id: @beekeeper.id,
        permission: @beekeeper.permission,
        apiary_id: @beekeeper.apiary_id,
        user: {
          user_id: @user.id,
          first_name: @user.first_name,
          last_name: @user.last_name
        }
      }.to_json

      expect(response).to be_success
      expect(response.body).to eq(beekeeper_json)
    end

    it 'does not allow users to view beekeepers at other apiaries' do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_apiary = FactoryGirl.create(:apiary, user_id: another_user.id)
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: another_apiary,
        creator: another_user.id
      )

      get apiary_beekeeper_path(another_apiary, another_beekeeper), format: :json
      expect(response.code).to eq("401")

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq("You are not authorized to perform this action.")
    end
  end

  describe '#create' do
    it 'creates a new Beekeeper in the database' do
      new_user = FactoryGirl.create(:user, email: "new_guy@example.com")
      payload = {
        beekeeper: {
          email: new_user.email,
          permission: 'Read'
        }
      }
      original_beek_count = Beekeeper.count

      post(apiary_beekeepers_path(@apiary), payload.to_json, @http_headers)

      expect(response).to be_success
      expect(Beekeeper.count).to be(original_beek_count + 1)
    end

    it 'returns a JSON representation of the new beekeeper object' do
      new_user = FactoryGirl.create(:user, email: "new_guy@example.com")
      payload = {
        beekeeper: {
          email: new_user.email,
          permission: 'Read'
        }
      }

      post(apiary_beekeepers_path(@apiary), payload.to_json, @http_headers)

      expect(response).to be_success

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["id"]).to_not be_nil
      expect(parsed_response["apiary_id"]).to be(@apiary.id)
      expect(parsed_response["permission"]).to eq("Read")
      expect(parsed_response["user"]["user_id"]).to be(new_user.id)
      expect(parsed_response["user"]["first_name"]).to eq(new_user.first_name)
      expect(parsed_response["user"]["last_name"]).to eq(new_user.last_name)
    end

    it 'will not allow users with write access to create beekeepers' do
      another_user = create_logged_in_user(email: 'another_user@example.com')
      write_beekeeper = FactoryGirl.create(:beekeeper,
                                           user: another_user,
                                           apiary: @apiary,
                                           creator: @user.id,
                                           permission: 'Write')


      yet_another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')

      payload = {
        beekeeper: {
          email: yet_another_user.email,
          permission: 'Write'
        }
      }

      original_beek_count = Beekeeper.count

      post(apiary_beekeepers_path(@apiary), payload.to_json, @http_headers)
      expect(response.code).to eq("401")

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq("You are not authorized to perform this action.")

      expect(Beekeeper.count).to be(original_beek_count)
    end

    it 'will not allow users with read access to create beekeepers' do
      another_user = create_logged_in_user(email: 'another_user@example.com')
      write_beekeeper = FactoryGirl.create(:beekeeper,
                                           user: another_user,
                                           apiary: @apiary,
                                           creator: @user.id,
                                           permission: 'Write')

      yet_another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')

      payload = {
        beekeeper: {
          email: yet_another_user.email,
          permission: 'Read'
        }
      }

      original_beek_count = Beekeeper.count

      post(apiary_beekeepers_path(@apiary), payload.to_json, @http_headers)
      expect(response.code).to eq("401")

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq("You are not authorized to perform this action.")

      expect(Beekeeper.count).to be(original_beek_count)
    end

    it 'will not allow random users to create beekeepers at different apiaries' do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')
      an_apiary = FactoryGirl.create(:apiary, user_id: a_user.id)

      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')

      payload = {
        beekeeper: {
          email: another_user.email,
          permission: 'Read'
        }
      }

      original_beek_count = Beekeeper.count

      post(apiary_beekeepers_path(an_apiary), payload.to_json, @http_headers)
      expect(response.code).to eq("401")

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq("You are not authorized to perform this action.")

      expect(Beekeeper.count).to be(original_beek_count)
    end
  end

  describe '#update' do
    it 'modifies an existing Beekeeper in the database' do
      new_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      new_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: new_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Read'
      )

      payload = {
        beekeeper: {
          permission: 'Write'
        }
      }

      expect(new_beekeeper.permission).to eq('Read')

      put(apiary_beekeeper_path(@apiary, new_beekeeper), payload.to_json, @http_headers)

      expect(response).to be_success

      new_beekeeper.reload

      expect(new_beekeeper.permission).to eq('Write')

      parsed_response = JSON.parse(response.body)

      expect(parsed_response["id"]).to be(new_beekeeper.id)
      expect(parsed_response["apiary_id"]).to be(@apiary.id)
      expect(parsed_response["permission"]).to eq("Write")
      expect(parsed_response["user"]["user_id"]).to be(new_user.id)
      expect(parsed_response["user"]["first_name"]).to eq(new_user.first_name)
      expect(parsed_response["user"]["last_name"]).to eq(new_user.last_name)
    end

    it 'will not allow users with write access to update beekeepers' do
      write_user = create_logged_in_user(email: 'write_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: write_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Write'
      )

      another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        creator: @user.id,
        permission: "Read"
      )

      payload = {
        beekeeper: {
          permission: 'Write'
        }
      }

      expect(another_beekeeper.permission).to eq('Read')

      put(apiary_beekeeper_path(@apiary, another_beekeeper), payload.to_json, @http_headers)
      expect(response.code).to eq("401")

      another_beekeeper.reload
      expect(another_beekeeper.permission).to eq('Read')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq("You are not authorized to perform this action.")
    end

    it 'will not allow users with read access to create beekeepers' do
      read_user = create_logged_in_user(email: 'read_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: read_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Write'
      )

      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        creator: @user.id,
        permission: "Read"
      )

      payload = {
        beekeeper: {
          permission: 'Write'
        }
      }

      expect(another_beekeeper.permission).to eq('Read')

      put(apiary_beekeeper_path(@apiary, another_beekeeper), payload.to_json, @http_headers)
      expect(response.code).to eq("401")

      another_beekeeper.reload
      expect(another_beekeeper.permission).to eq('Read')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq("You are not authorized to perform this action.")
    end

    it 'will not allow random users to edit beekeepers at different apiaries' do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')

      different_apiary = FactoryGirl.create(:apiary, user_id: a_user.id)
      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: different_apiary,
        creator: a_user.id,
        permission: 'Read'
      )

      payload = {
        beekeeper: {
          permission: 'Admin'
        }
      }

      expect(a_beekeeper.permission).to eq('Read')

      put(apiary_beekeeper_path(different_apiary, a_beekeeper), payload.to_json, @http_headers)
      expect(response.code).to eq('401')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action.')

      a_beekeeper.reload
      expect(a_beekeeper.permission).to eq('Read')
    end

    it "does not allow admin to demote other admin" do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')

      another_admin = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Admin'
      )

      expect(another_admin.permission).to eq('Admin')

      payload = {
        beekeeper: {
          permission: 'Read'
        }
      }

      put(apiary_beekeeper_path(@apiary, another_admin), payload.to_json, @http_headers)
      expect(response.code).to eq('401')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action.')

      another_admin.reload
      expect(another_admin.permission).to eq('Admin')
    end
  end

  describe "#destroy" do
    it "allows admins to remove beekeepers" do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')

      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Read'
      )

      delete(apiary_beekeeper_path(@apiary, a_beekeeper), nil, @http_headers)
      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body["head"]).to eq("no_content")

      expect { a_beekeeper.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not allow users to remove beekeepers from other apiaries" do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')

      different_apiary = FactoryGirl.create(:apiary, user_id: a_user.id)

      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: different_apiary,
        creator: a_user.id,
        permission: 'Read'
      )

      delete(apiary_beekeeper_path(different_apiary, a_beekeeper), nil, @http_headers)
      expect(response.code).to eq('401')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action.')

      expect { a_beekeeper.reload }.not_to raise_error
    end

    it "does not allow write users to remove beekeepers" do
      write_user = create_logged_in_user(email: 'write_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: write_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Write'
      )

      delete(apiary_beekeeper_path(@apiary, @beekeeper), nil, @http_headers)
      expect(response.code).to eq('401')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action.')

      expect { @beekeeper.reload }.not_to raise_error
    end

    it "does not allow read users to remove beekeepers" do
      read_user = create_logged_in_user(email: 'read_user@example.com')
      read_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: read_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Read'
      )

      delete(apiary_beekeeper_path(@apiary, @beekeeper), nil, @http_headers)
      expect(response.code).to eq('401')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action.')

      expect { @beekeeper.reload }.not_to raise_error
    end

    it "allows admins to remove themselves" do
      delete(apiary_beekeeper_path(@apiary, @beekeeper), nil, @http_headers)

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body["head"]).to eq("no_content")

      expect { @beekeeper.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not allow admins to remove other admins" do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')

      another_admin = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        creator: @user.id,
        permission: 'Admin'
      )

      delete(apiary_beekeeper_path(@apiary, another_admin), nil, @http_headers)
      expect(response.code).to eq('401')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action.')
      expect { another_admin.reload }.not_to raise_error
      expect(another_admin.permission).to eq('Admin')
    end
  end
end
