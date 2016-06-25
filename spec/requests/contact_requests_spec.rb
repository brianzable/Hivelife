require 'rails_helper'

RSpec.describe ContactRequestsController, type: :request do
  describe 'create' do
    it 'returns a 201 when creating a contact request' do
      payload = {
        contact_request: {
          name: 'Random User',
          email_address: 'user@example.com',
          subject: 'Some feedback about the site',
          message: 'It works'
        },
        format: :json
      }

      post contact_requests_path, payload

      expect(response).to have_http_status(201)
    end

    it 'creates a contact request with the correct attributes' do
      payload = {
        contact_request: {
          name: 'Random User',
          email_address: 'user@example.com',
          subject: 'Some feedback about the site',
          message: 'It works'
        },
        format: :json
      }

      expect do
        post contact_requests_path, payload
      end.to change { ContactRequest.count }.by(1)

      contact_request = ContactRequest.last

      expect(contact_request.name).to eq('Random User')
      expect(contact_request.email_address).to eq('user@example.com')
      expect(contact_request.subject).to eq('Some feedback about the site')
      expect(contact_request.message).to eq('It works')
    end

    it 'returns a 422 when there are errors' do
      payload = {
        contact_request: {
          name: 'Random User',
          email_address: nil,
          subject: 'Some feedback about the site',
          message: 'It works'
        },
        format: :json
      }

      post contact_requests_path, payload

      expect(response).to have_http_status(422)
    end

    it 'returns errors when the payload is invalid' do
      payload = {
        contact_request: {
          name: 'Random User',
          email_address: nil,
          subject: 'Some feedback about the site',
          message: 'It works'
        },
        format: :json
      }

      expect do
        post contact_requests_path, payload
      end.to_not change { ContactRequest.count }

      parsed_body = JSON.parse(response.body)
      expect(parsed_body).to eq(["Email address can't be blank"])
    end
  end
end
