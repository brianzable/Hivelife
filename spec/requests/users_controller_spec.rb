require 'rails_helper'

RSpec.describe UsersController, type: :request do

  let!(:user) { create_logged_in_user }
  let!(:headers) { { 'Authorization' => "Token token=#{user.authentication_token}" } }

  describe '#show' do
    it 'returns a json representation of a user' do
      get profile_users_path, { format: :json }, headers

      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('user@example.com')
      expect(parsed_body['authentication_token']).to_not be_nil
    end
  end

  describe '#create' do
    it 'allows anyone to signup for an account using an email and password' do
      payload = {
        user: {
          email: 'another_user@example.com',
          password: '11111111',
          password_confirmation: '11111111',
          first_name: 'John',
          last_name: 'Doe',
          timezone: 'UTC'
        },
        format: :json
      }

      expect do
        post users_path, payload
      end.to change { User.count }.by(1)

      expect(response.status).to eq(201)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('another_user@example.com')
      expect(parsed_body['timezone']).to eq('UTC')

      user = User.last
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
      expect(user.timezone).to eq('UTC')
      expect(user.email).to eq('another_user@example.com')
      expect(user.password).to_not eq('11111111')
    end

    it 'sends an activation email when signing up a new user' do
      payload = {
        user: {
          email: 'user229@example.com',
          password: '11111111',
          password_confirmation: '11111111'
        },
        format: :json
      }

      expect do
        post users_path, payload
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response.status).to eq(201)

      email_message = ActionMailer::Base.deliveries.last
      body = email_message.body.encoded
      user = User.last
      url = "https://hivelife.co/users/#{user.activation_token}/activate"
      expect(email_message.subject).to eq("Verify your Hivelife account!")
      expect(email_message.to).to eq(["user229@example.com"])
      expect(body).to include(url)
    end

    it 'requires that password and password confirmation fields match' do
      payload = {
        user: {
          email: 'user229@example.com',
          password: '22222222',
          password_confirmation: '11111111'
        },
        format: :json
      }

      expect do
        post users_path, payload
      end.to_not change { User.count }

      expect(response.status).to eq(422)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq(["Password confirmation doesn't match Password"])
    end
  end

  describe '#update' do
    it 'allows users to update their information' do
      payload = {
        user: { email: 'new_email@example.com' },
        format: :json
      }

      put user_path(user), payload, headers

      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('new_email@example.com')
    end

    it 'does not require password fields when updating user information' do
      payload = {
        user: { email: 'new_email@example.com' },
        format: :json
      }

      put user_path(user), payload, headers

      expect(response.status).to eq(200)
    end

    it 'only allows users to edit their own information' do
      another_user = FactoryGirl.create(:user)

      payload = {
        id: another_user.id,
        user: { email: 'new_email@example.com' },
        format: :json
      }

      put user_path(another_user), payload, headers

      expect(response.status).to eq(404)
    end
  end

  describe 'destroy' do
    it 'allows users to delete their own accounts' do
      expect do
        delete user_path(user), { format: :json }, headers
      end.to change { User.count }.by(-1)

      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['head']).to eq('no_content')
    end

    it 'requires users to be logged in' do
      expect do
        delete user_path(user), { format: :json }, {}
      end.to_not change { User.count }

      expect(response.status).to eq(401)
    end

    it 'does not allow users to delete random accounts' do
      random_user = FactoryGirl.create(:user)

      expect do
        delete user_path(random_user), { format: :json }, headers
      end.to_not change { User.count }

      expect(response.status).to eq(404)
    end
  end

  describe 'activate' do
    it 'returns a 200 when succesfully activating an account' do
      user = FactoryGirl.create(:user)

      get user_activation_path(user.activation_token), format: :json

      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['head']).to eq('no_content')
    end

    it 'returns a 400 when trying to activate a non-existent user' do
      get user_activation_path('bad-token'), format: :json

      expect(response.status).to eq(400)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['head']).to eq('no_content')
    end
  end
end
