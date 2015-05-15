require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  render_views

  describe '#show' do
    it 'returns a json representation of a user' do
      user = User.create(
        email: 'user@example.com',
        password: '11111111',
        password_confirmation: '11111111'
      )
      login_user(user)

      get :show, id: user.id, format: :json

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('user@example.com')
      expect(parsed_body['authentication_token']).to_not be_nil
    end

    it 'only allows users to look at their own information' do
      user = FactoryGirl.create(:user)
      login_user(user)

      another_user = FactoryGirl.create(:user)

      get :show, id: another_user.id, format: :json

      expect(response.code).to eq('401')
    end
  end

  describe '#create' do
    it 'allows anyone to signup for an account using an email and password' do
      payload = {
        user: {
          email: 'user@example.com',
          password: '11111111',
          password_confirmation: '11111111'
        },
        format: :json
      }

      expect do
        post :create, payload
      end.to change { User.count }.by(1)

      expect(response.code).to eq('201')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('user@example.com')
    end

    it 'sends an activation email when signing up a new user' do
      payload = {
        user: {
          email: 'user@example.com',
          password: '11111111',
          password_confirmation: '11111111'
        },
        format: :json
      }

      expect do
        post :create, payload
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response.code).to eq('201')

      email_message = ActionMailer::Base.deliveries.last
      body = email_message.body.encoded
      user = User.last
      url = "https://hivelife.co/users/#{user.activation_token}/activate"
      expect(email_message.subject).to eq("Verify your Hivelife account!")
      expect(email_message.to).to eq(["user@example.com"])
      expect(body).to include(url)
    end
  end

  describe '#update' do
    it 'allows users to update their information' do
      user = FactoryGirl.create(:user)
      login_user(user)

      payload = {
        id: user.id,
        user: { email: 'new_email@example.com' },
        format: :json
      }

      put :update, payload

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('new_email@example.com')
    end

    it 'does not require password fields when updating user information' do
      user = FactoryGirl.create(:user)
      login_user(user)

      payload = {
        id: user.id,
        user: { email: 'new_email@example.com' },
        format: :json
      }

      put :update, payload

      expect(response.code).to eq('200')
    end

    it 'only allows users to edit their own information' do
      user = FactoryGirl.create(:user)
      login_user(user)

      another_user = FactoryGirl.create(:user)

      payload = {
        id: another_user.id,
        user: { email: 'new_email@example.com' },
        format: :json
      }

      put :update, payload

      expect(response.code).to eq('401')
    end
  end

  describe 'destroy' do
    it 'allows users to delete their own accounts' do
      user = FactoryGirl.create(:user)
      login_user(user)

      expect do
        delete :destroy, id: user.id, format: :json
      end.to change { User.count }.by(-1)

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['head']).to eq('no_content')
    end

    it 'requires users to be logged in' do
      user = FactoryGirl.create(:user)

      expect do
        delete :destroy, id: user.id, format: :json
      end.to_not change { User.count }

      expect(response.code).to eq("401")

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action')
    end

    it 'does not allow users to delete random accounts' do
      troll = FactoryGirl.create(:user)
      login_user(troll)

      random_user = FactoryGirl.create(:user)

      expect do
        delete :destroy, id: random_user.id, format: :json
      end.to_not change { User.count }

      expect(response.code).to eq("401")

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['error']).to eq('You are not authorized to perform this action')
    end
  end

  describe 'activate' do
    it 'returns a 200 when succesfully activating an account' do
      user = FactoryGirl.create(:user)

      get :activate, activation_token: user.activation_token, format: :json

      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['head']).to eq('no_content')
    end

    it 'returns a 400 when trying to activate a non-existent user' do
      get :activate, activation_token: 'bad-token', format: :json

      expect(response.status).to eq(400)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['head']).to eq('no_content')
    end
  end
end
