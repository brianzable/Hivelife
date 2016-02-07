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

  describe 'photo_url' do
    it 'saves the Gravatar photo URL on create' do
      user = User.new(
        email: 'user@example.com',
        password: '11111111',
        password_confirmation: '11111111'
      )
      expect(user.photo_url).to be_nil

      user.save!
      expect(user.photo_url).to eq('http://www.gravatar.com/avatar/b58996c504c5638798eb6b511e6f49af?s=200')
    end
  end
end
