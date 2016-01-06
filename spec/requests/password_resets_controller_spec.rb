require 'rails_helper'

RSpec.describe PasswordResetsController, type: :request do
  let!(:user) do
    FactoryGirl.create(
      :user,
      email: 'user@example.com',
      password: '11111111',
      password_confirmation: '11111111',
      first_name: 'Pat',
      last_name: 'Doe',
    )
  end

  describe 'create' do
    it 'sends an email to the user' do
      payload = {
        email: 'user@example.com',
        format: :json
      }

      expect do
        post password_resets_path, payload
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response.status).to eq(201)

      message = ActionMailer::Base.deliveries.last

      expect(message.to).to eq(['user@example.com'])
      expect(message.subject).to eq('Hivelife Password Reset')
      expect(message.encoded).to include('Pat Doe')
    end

    it 'returns success even when the user cannot be found' do
      payload = {
        email: 'non_existent@something.com',
        format: :json
      }

      expect do
        post password_resets_path, payload
      end.to_not change { ActionMailer::Base.deliveries.count }

      expect(response.status).to eq(201)
    end
  end

  describe 'update' do
    before(:each) do
      post password_resets_path, { email: user.email, format: :json }
      user.reload
    end

    it 'changes the password if the token and new passwords are valid' do
      payload = {
        user: {
          password: 'newpassword',
          password_confirmation: 'newpassword',
        },
        format: :json
      }

      put password_reset_path(user.reset_password_token), payload
      expect(response.status).to eq(200)

      user.reload
      expect(user).to be_valid_password('newpassword')
    end

    it 'returns errors if the passwords do not match' do
      payload = {
        user: {
          password: 'newpassword',
          password_confirmation: 'something_different',
        },
        format: :json
      }

      put password_reset_path(user.reset_password_token), payload
      expect(response.status).to eq(422)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq(["Password confirmation doesn't match Password"])
    end

    it 'returns errors if the password is invalid' do
      payload = {
        user: {
          password: 'abc',
          password_confirmation: 'abc'
        },
        format: :json
      }

      put password_reset_path(user.reset_password_token), payload
      expect(response.status).to eq(422)

      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq(["Password is too short (minimum is 8 characters)"])
    end

    it 'returns errors if the password reset token has expired' do
      user.reset_password_token_expires_at = Time.now
      user.save!

      payload = {
        user: {
          password: '99999999',
          password_confirmation: '99999999'
        },
        format: :json
      }

      put password_reset_path(user.reset_password_token), payload
      expect(response.status).to eq(404)
    end

    it 'returns a 404 if user cannot be found from password reset token' do
      put password_reset_path('aaaa')
      expect(response.status).to eq(404)
    end
  end
end
