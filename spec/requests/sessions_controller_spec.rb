require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  let!(:user) do
    user = FactoryGirl.create(
      :user,
      email: 'user@example.com',
      password: '11111111'
    )
    user.activate!
    user
  end

  describe 'sign_in' do
    it 'returns a token given a username and password' do
      payload = {
        email: 'user@example.com',
        password: '11111111',
        format: :json
      }

      post sign_in_path, payload

      expect(response.status).to eq(200)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq({
        'session' => {
          'authentication_token' => user.authentication_token
        }
      })
    end

    it 'returns a 422 when failing to sign in the user' do
      payload = {
        email: 'user@example.com',
        password: '11111',
        format: :json
      }

      post sign_in_path, payload

      expect(response.status).to eq(422)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq({
        'error' => 'Invalid credentials'
      })
    end
  end
end
