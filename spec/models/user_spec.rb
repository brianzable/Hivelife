require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'authentication_token' do
    it 'creates an authentication token prior to saving' do
      user = User.new(
        email: 'user@example.com',
        password: '11111111',
        password_confirmation: '11111111'
      )

      user.save

      expect(user.authentication_token).to_not be_nil
    end
  end
end
