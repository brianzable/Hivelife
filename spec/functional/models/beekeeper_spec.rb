require 'rails_helper'

describe Beekeeper do
  describe 'admin?' do
    it 'returns true if the permission is Admin' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Admin')
      expect(beekeeper.admin?).to be(true)
    end

    it 'returns false if the permission is Read' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Read')
      expect(beekeeper.admin?).to be(false)
    end

    it 'returns false if the permission is Write' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Write')
      expect(beekeeper.admin?).to be(false)
    end
  end

  describe 'read?' do
    it 'returns true if the permission is Admin' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Admin')
      expect(beekeeper.read?).to be(true)
    end

    it 'returns true if the permission is Read' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Read')
      expect(beekeeper.read?).to be(true)
    end

    it 'returns true if the permission is Write' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Write')
      expect(beekeeper.read?).to be(true)
    end
  end

  describe 'write?' do
    it 'returns true if the permission is Admin' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Admin')
      expect(beekeeper.write?).to be(true)
    end

    it 'returns false if the permission is Read' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Read')
      expect(beekeeper.write?).to be(false)
    end

    it 'returns true if the permission is Write' do
      beekeeper = FactoryGirl.build(:beekeeper, permission: 'Write')
      expect(beekeeper.write?).to be(true)
    end
  end
end

