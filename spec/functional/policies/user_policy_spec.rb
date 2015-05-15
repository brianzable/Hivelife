require 'rails_helper'

describe UserPolicy, type: :model do
  before(:all) do
    @user = FactoryGirl.build(:user)
    @record = FactoryGirl.build(:user)
  end

  describe 'show?' do
    it 'returns true when the user and record are the same' do
      policy = UserPolicy.new(@user, @user)
      expect(policy.show?).to be(true)
    end

    it 'returns false when the user and record are not the same' do
      policy = UserPolicy.new(@user, @record)
      expect(policy.show?).to be(false)
    end
  end

  describe 'update?' do
    it 'returns true when the user and record are the same' do
      policy = UserPolicy.new(@user, @user)
      expect(policy.update?).to be(true)
    end

    it 'returns false when the user and record are not the same' do
      policy = UserPolicy.new(@user, @record)
      expect(policy.update?).to be(false)
    end
  end

  describe 'destroy?' do
    it 'returns true when the user and record are the same' do
      policy = UserPolicy.new(@user, @user)
      expect(policy.destroy?).to be(true)
    end

    it 'returns false when the user and record are not the same' do
      policy = UserPolicy.new(@user, @record)
      expect(policy.destroy?).to be(false)
    end
  end
end
