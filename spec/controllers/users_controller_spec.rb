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

      get :show, id: user.id, format: :json

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('user@example.com')
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
  end

  describe '#update' do
    it 'allows users to update their information' do
      user = User.create(
        email: 'user@example.com',
        password: '11111111',
        password_confirmation: '11111111'
      )

      payload = {
        id: user.id,
        user: {
          email: 'new_email@example.com',
          password: '11111111',
          password_confirmation: '11111111'
        },
        format: :json
      }

      put :update, payload

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['id']).to_not be_nil
      expect(parsed_body['email']).to eq('new_email@example.com')
    end

    it 'requires password fields when updating user information' do
      user = User.create(
        email: 'user@example.com',
        password: '11111111',
        password_confirmation: '11111111'
      )

      payload = {
        id: user.id,
        user: {
          email: 'new_email@example.com'
        },
        format: :json
      }

      put :update, payload

      expect(response.code).to eq('422')
    end
  end

  describe 'destroy' do
    it 'allows users to delete their own accounts' do
      user = User.create(
        email: 'user@example.com',
        password: '11111111',
        password_confirmation: '11111111'
      )

      expect do
        delete :destroy, id: user.id, format: :json
      end.to change { User.count }.by(-1)

      expect(response.code).to eq('200')

      parsed_body = JSON.parse(response.body)
      expect(parsed_body['head']).to eq('no_content')
    end
  end
end
