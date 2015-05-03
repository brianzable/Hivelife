require 'rails_helper'

RSpec.describe ApiariesController, type: :controller do
  render_views

  before(:each) do
    @user = create_logged_in_user
  end

  describe '#index' do
    it "returns a list of the user's apiaries" do
      apiary_with_hives = FactoryGirl.create(:apiary_with_hives)
      another_apiary_with_hives = FactoryGirl.create(:apiary_with_hives)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary_with_hives,
        user: @user,
      )

      FactoryGirl.create(
        :beekeeper,
        apiary: another_apiary_with_hives,
        user: @user,
      )

      get :index, format: :json
      apiaries = JSON.parse(response.body)

      expect(apiaries.count).to be(2)

      first_apiary = apiaries[0]
      expect(first_apiary["id"]).to eq(apiary_with_hives.id)
      expect(first_apiary["name"]).to eq(apiary_with_hives.name)
      expect(first_apiary["photo_url"]).to eq(apiary_with_hives.photo_url)
      expect(first_apiary["city"]).to eq(apiary_with_hives.city)
      expect(first_apiary["state"]).to eq(apiary_with_hives.state)
      expect(first_apiary["zip_code"]).to eq(apiary_with_hives.zip_code)

      first_apiary_hives = first_apiary["hives"]
      expect(first_apiary_hives.count).to be(2)
      expect(first_apiary_hives[0]["id"]).to_not be_nil
      expect(first_apiary_hives[0]["name"]).to_not be_nil

      second_apiary = apiaries[1]
      expect(second_apiary["id"]).to eq(another_apiary_with_hives.id)

      second_apiary_hives = second_apiary["hives"]
      expect(second_apiary_hives.count).to be(2)
    end
  end

  describe '#show' do
    it 'allows users who are memeber of an apiary to view apiary information' do
      apiary_with_hives = FactoryGirl.create(:apiary_with_hives)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary_with_hives,
        user: @user
      )

      get :show, id: apiary_with_hives.id, format: :json

      apiary = JSON.parse(response.body)

      expect(apiary["id"]).to eq(apiary_with_hives.id)
      expect(apiary["name"]).to eq(apiary_with_hives.name)
      expect(apiary["photo_url"]).to eq(apiary_with_hives.photo_url)
      expect(apiary["city"]).to eq(apiary_with_hives.city)
      expect(apiary["state"]).to eq(apiary_with_hives.state)
      expect(apiary["zip_code"]).to eq(apiary_with_hives.zip_code)

      hives = apiary["hives"]
      expect(hives.count).to be(2)
      expect(hives[0]["id"]).to_not be_nil
      expect(hives[0]["name"]).to_not be_nil
    end

    it 'does not allow users who are not members at an apiary to view an apiary' do
      apiary_with_hives = FactoryGirl.create(:apiary_with_hives)
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

      get :show, id: apiary_with_hives.id, format: :json
      expect(response.code).to eq("401")

      parsed_body = JSON.parse(response.body)
      expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
    end

    it 'contains a list of hives associated with this apiary' do
      apiary_with_hives = FactoryGirl.create(:apiary_with_hives)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary_with_hives,
        user: @user
      )

      get :show, id: apiary_with_hives.id, format: :json
      apiary = JSON.parse(response.body)

      hives = apiary["hives"]
      expect(hives.count).to be(2)
      expect(hives[0]["id"]).to_not be_nil
      expect(hives[0]["name"]).to_not be_nil
    end
  end

  describe '#create' do
    it 'creates and returns a JSON representation of the apiary' do
      payload = {
        apiary: {
          name: 'New Apiary',
          zip_code: '60606',
        },
        format: :json
      }

      expect do
        post :create, payload

        parsed_body = JSON.parse(response.body)

        expect(parsed_body["id"]).to_not be_nil
        expect(parsed_body["zip_code"]).to eq("60606")
        expect(parsed_body["photo_url"]).to_not be_nil
      end.to change { Apiary.count }
    end

    it 'returns a JSON representation of validation errors when not given required data' do
      payload = {
        apiary: {
          zip_code: '60606'
        },
        format: :json
      }

      expect do
        post :create, payload

        parsed_body = JSON.parse(response.body)
        expect(parsed_body["name"].first).to eq("Apiary name cannot be blank")
      end.to_not change { Apiary.count }
    end

    it 'creates a beekeeper object making the creator an admin at the new apiary' do
      payload = {
        apiary: {
          name: 'New Apiary',
          zip_code: '60606'
        },
        format: :json
      }

      expect(Beekeeper.find_by_user_id(@user.id)).to be_nil

      post :create, payload
      parsed_body = JSON.parse(response.body)

      beekeeper = Beekeeper.last
      expect(beekeeper.permission).to eq('Admin')
      expect(beekeeper.apiary_id).to eq(parsed_body['id'])
    end
  end

  describe '#update' do
    it 'allows an administator of an apiary to change apiary information' do
      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: @user,
      )

      payload = {
        apiary: {
          city: 'Chicago'
        },
        id: apiary.id,
        format: :json
      }

      put :update, payload

      parsed_body = JSON.parse(response.body)
      expect(parsed_body["city"]).to eq("Chicago")
    end

    it 'does not allow users with read permissions to update an apiary' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: unauthorized_user,
        permission: 'Read'
      )

      payload = {
        apiary: {
          city: 'Chicago'
        },
        id: apiary.id,
        format: :json
      }

      put :update, payload

      parsed_body = JSON.parse(response.body)
      expect(response.code).to eq("401")
      expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
    end

    it 'does not allow users with write permissions to update an apiary' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: unauthorized_user,
        permission: 'Write'
      )

      payload = {
        apiary: {
          city: 'Chicago'
        },
        id: apiary.id,
        format: :json
      }

      put :update, payload

      parsed_body = JSON.parse(response.body)
      expect(response.code).to eq("401")
      expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
    end

    it 'does not allow administrators of other apiaries to update other apiaries' do
      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: @user
      )

      another_apiary = FactoryGirl.create(:apiary)

      payload = {
        apiary: {
          city: 'Chicago'
        },
        id: another_apiary.id,
        format: :json
      }

      put :update, payload

      parsed_body = JSON.parse(response.body)
      expect(response.code).to eq("401")
      expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
    end
  end

  describe '#destroy' do
    it 'allows admins at an apiary to delete an apiary' do
      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: @user
      )

      expect do
        delete :destroy, id: apiary.id, format: :json

        parsed_body = JSON.parse(response.body)
        expect(response.code).to eq('200')
        expect(parsed_body["head"]).to eq("no_content")
      end.to change{ Apiary.count }.by(-1)
    end

    it 'removes all beekeepers associated with this apiary' do
      apiary = FactoryGirl.create(:apiary)

      beekeeper = FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: @user
      )

      expect do
        delete :destroy, id: apiary.id, format: :json

        expect(response.code).to eq('200')
        expect{@user.reload}.to_not raise_error
      end.to change{ Beekeeper.count }.by(-1)
    end

    it 'removes all hives associated with this apiary' do
      apiary = FactoryGirl.create(:apiary_with_hives)

      beekeeper = FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: @user
      )

      expect do
        delete :destroy, id: apiary.id, format: :json

        expect(response.code).to eq('200')
      end.to change{ Hive.count }.by(-2)
    end

    it 'does not allow users with read permissions to destroy an apiary' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: unauthorized_user,
        permission: 'Read'
      )

      expect do
        delete :destroy, id: apiary.id, format: :json

        parsed_body = JSON.parse(response.body)
        expect(response.code).to eq("401")
        expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end.to_not change { Apiary.count }
    end

    it 'does not allow users with write permissions to destroy an apiary' do
      unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: unauthorized_user,
        permission: 'Read'
      )

      expect do
        delete :destroy, id: apiary.id, format: :json

        parsed_body = JSON.parse(response.body)
        expect(response.code).to eq("401")
        expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end.to_not change { Apiary.count }
    end

    it 'does not allow users to destroy random apiaries' do
      apiary = FactoryGirl.create(:apiary)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary,
        user: @user
      )

      another_apiary = FactoryGirl.create(:apiary)
      expect do
        delete :destroy, id: another_apiary.id, format: :json

        parsed_body = JSON.parse(response.body)
        expect(response.code).to eq("401")
        expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end.to_not change{ Apiary.count }
    end
  end
end
