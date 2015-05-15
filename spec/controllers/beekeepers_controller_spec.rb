require 'rails_helper'

RSpec.describe BeekeepersController, type: :controller do
  render_views

  before(:each) do
    @user = create_logged_in_user
    @apiary = FactoryGirl.create(:apiary)
    @beekeeper = FactoryGirl.create(
      :beekeeper,
      user: @user,
      apiary: @apiary
    )
  end

  describe '#show' do
    it 'returns a JSON representation of a beekeeper' do
      get :show, apiary_id: @apiary.id, id: @beekeeper.id, format: :json

      beekeeper_json = {
        id: @beekeeper.id,
        permission: @beekeeper.permission,
        apiary_id: @beekeeper.apiary_id,
      }.to_json

      expect(response).to be_success
      expect(response.body).to eq(beekeeper_json)
    end

    it 'does not allow users to view beekeepers at other apiaries' do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_apiary = FactoryGirl.create(:apiary)
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: another_apiary,
      )

      get :show, apiary_id: another_apiary.id, id: another_beekeeper.id, format: :json
      expect(response.code).to eq("401")
    end
  end

  describe '#create' do
    it 'creates a new Beekeeper in the database' do
      new_user = FactoryGirl.create(:user, email: "new_guy@example.com")
      payload = {
        apiary_id: @apiary.id,
        beekeeper: {
          email: new_user.email,
          permission: 'Read'
        },
        format: :json
      }

      expect do
        post :create, payload
      end.to change {Beekeeper.count}.by(1)

      expect(response).to be_success
    end

    it 'returns a JSON representation of the new beekeeper object' do
      new_user = FactoryGirl.create(:user, email: "new_guy@example.com")
      payload = {
        apiary_id: @apiary.id,
        beekeeper: {
          email: new_user.email,
          permission: 'Read'
        },
        format: :json
      }

      post :create, payload

      expect(response).to be_success

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["id"]).to_not be_nil
      expect(parsed_response["apiary_id"]).to be(@apiary.id)
      expect(parsed_response["permission"]).to eq("Read")
    end

    it 'will not allow users with write access to create beekeepers' do
      another_user = create_logged_in_user(email: 'another_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        permission: 'Write'
      )

      yet_another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')

      payload = {
        apiary_id: @apiary.id,
        beekeeper: {
          email: yet_another_user.email,
          permission: 'Write'
        },
        format: :json
      }

      expect do
        post :create, payload
      end.to_not change { Beekeeper.count }

      expect(response.code).to eq("401")
    end

    it 'will not allow users with read access to create beekeepers' do
      another_user = create_logged_in_user(email: 'another_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        permission: 'Write'
      )

      yet_another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')

      payload = {
        apiary_id: @apiary.id,
        beekeeper: {
          email: yet_another_user.email,
          permission: 'Read'
        },
        format: :json
      }

      expect do
        post :create, payload
      end.to_not change { Beekeeper.count }

      expect(response.code).to eq("401")
    end

    it 'will not allow random users to create beekeepers at different apiaries' do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')
      an_apiary = FactoryGirl.create(:apiary)

      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')

      payload = {
        apiary_id: an_apiary.id,
        beekeeper: {
          email: another_user.email,
          permission: 'Read'
        },
        format: :json
      }

      expect do
        post :create, payload
      end.to_not change { Beekeeper.count }

      expect(response.code).to eq("401")
    end
  end

  describe '#update' do
    it 'modifies an existing Beekeeper in the database' do
      new_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      new_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: new_user,
        apiary: @apiary,
        permission: 'Read'
      )

      payload = {
        id: new_beekeeper.id,
        apiary_id: @apiary.id,
        beekeeper: {
          permission: 'Write'
        },
        format: :json
      }

      expect(new_beekeeper.permission).to eq('Read')

      put :update, payload

      new_beekeeper.reload
      expect(new_beekeeper.permission).to eq('Write')

      expect(response).to be_success

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["id"]).to be(new_beekeeper.id)
      expect(parsed_response["apiary_id"]).to be(@apiary.id)
      expect(parsed_response["permission"]).to eq("Write")
    end

    it 'will not allow users with write access to update beekeepers' do
      write_user = create_logged_in_user(email: 'write_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: write_user,
        apiary: @apiary,
        permission: 'Write'
      )

      another_user = FactoryGirl.create(:user, email: 'yet_another_user@example.com')
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        permission: "Read"
      )

      payload = {
        id: another_beekeeper.id,
        apiary_id: @apiary.id,
        beekeeper: {
          permission: 'Write'
        },
        format: :json
      }

      expect(another_beekeeper.permission).to eq('Read')

      put :update, payload

      another_beekeeper.reload
      expect(another_beekeeper.permission).to eq('Read')

      expect(response.code).to eq("401")
    end

    it 'will not allow users with read access to create beekeepers' do
      read_user = create_logged_in_user(email: 'read_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: read_user,
        apiary: @apiary,
        permission: 'Write'
      )

      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')
      another_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        permission: "Read"
      )

      payload = {
        id: another_beekeeper.id,
        apiary_id: @apiary.id,
        beekeeper: {
          permission: 'Write'
        },
        format: :json
      }

      expect(another_beekeeper.permission).to eq('Read')

      put :update, payload

      another_beekeeper.reload
      expect(another_beekeeper.permission).to eq('Read')

      expect(response.code).to eq("401")
    end

    it 'will not allow random users to edit beekeepers at different apiaries' do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')

      different_apiary = FactoryGirl.create(:apiary)
      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: different_apiary,
        permission: 'Read'
      )

      payload = {
        id: a_beekeeper.id,
        apiary_id: different_apiary.id,
        beekeeper: {
          permission: 'Admin'
        },
        format: :json
      }

      expect(a_beekeeper.permission).to eq('Read')

      put :update, payload

      a_beekeeper.reload
      expect(a_beekeeper.permission).to eq('Read')

      expect(response.code).to eq('401')
    end

    it "does not allow admin to demote other admin" do
      another_user = FactoryGirl.create(:user, email: 'another_user@example.com')

      another_admin = FactoryGirl.create(
        :beekeeper,
        user: another_user,
        apiary: @apiary,
        permission: 'Admin'
      )

      expect(another_admin.permission).to eq('Admin')

      payload = {
        id: another_admin.id,
        apiary_id: @apiary.id,
        beekeeper: {
          permission: 'Read'
        },
        format: :json
      }

      put :update, payload

      expect(response.code).to eq('401')

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
        permission: 'Read'
      )

      expect do
        delete :destroy, apiary_id: @apiary.id, id: a_beekeeper.id, format: :json
      end.to change { Beekeeper.count }.by(-1)

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body["head"]).to eq("no_content")

      expect { a_beekeeper.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not allow users to remove beekeepers from other apiaries" do
      a_user = FactoryGirl.create(:user, email: 'a_user@example.com')

      different_apiary = FactoryGirl.create(:apiary)

      a_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: a_user,
        apiary: different_apiary,
        permission: 'Read'
      )

      expect do
        delete :destroy, apiary_id: different_apiary.id, id: a_beekeeper.id, format: :json
      end.to_not change { Beekeeper.count }

      expect(response.code).to eq('401')

      expect { a_beekeeper.reload }.not_to raise_error
    end

    it "does not allow write users to remove beekeepers" do
      write_user = create_logged_in_user(email: 'write_user@example.com')
      write_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: write_user,
        apiary: @apiary,
        permission: 'Write'
      )

      expect do
        delete :destroy, apiary_id: @apiary.id, id: @beekeeper.id, format: :json
      end.to_not change { Beekeeper.count }

      expect(response.code).to eq('401')

      expect { @beekeeper.reload }.not_to raise_error
    end

    it "does not allow read users to remove beekeepers" do
      read_user = create_logged_in_user(email: 'read_user@example.com')
      read_beekeeper = FactoryGirl.create(
        :beekeeper,
        user: read_user,
        apiary: @apiary,
        permission: 'Read'
      )

      expect do
        delete :destroy, apiary_id: @apiary.id, id: @beekeeper.id, format: :json
      end.to_not change { Beekeeper.count }

      expect(response.code).to eq('401')

      expect { @beekeeper.reload }.not_to raise_error
    end

    it "allows admins to remove themselves" do
      expect do
        delete :destroy, apiary_id: @apiary.id, id: @beekeeper.id, format: :json
      end.to change { Beekeeper.count }.by(-1)

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
        permission: 'Admin'
      )

      expect do
        delete :destroy, apiary_id: @apiary.id, id: another_admin.id, format: :json
      end.to_not change { Beekeeper.count }

      expect(response.code).to eq('401')

      expect { another_admin.reload }.not_to raise_error
      expect(another_admin.permission).to eq('Admin')
    end
  end
end
