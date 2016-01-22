require 'rails_helper'

describe Beekeeper, type: :model do
  describe 'admin?' do
    it 'returns true if the permission is Admin' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Admin)
      expect(beekeeper.admin?).to be(true)
    end

    it 'returns false if the permission is Read' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Viewer)
      expect(beekeeper.admin?).to be(false)
    end

    it 'returns false if the permission is Write' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Inspector)
      expect(beekeeper.admin?).to be(false)
    end
  end

  describe 'read?' do
    it 'returns true if the permission is Admin' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Admin)
      expect(beekeeper.read?).to be(true)
    end

    it 'returns true if the permission is Read' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Viewer)
      expect(beekeeper.read?).to be(true)
    end

    it 'returns true if the permission is Write' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Inspector)
      expect(beekeeper.read?).to be(true)
    end
  end

  describe 'write?' do
    it 'returns true if the permission is Admin' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Admin)
      expect(beekeeper.write?).to be(true)
    end

    it 'returns false if the permission is Read' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Viewer)
      expect(beekeeper.write?).to be(false)
    end

    it 'returns true if the permission is Write' do
      beekeeper = FactoryGirl.build(:beekeeper, role: Beekeeper::Roles::Inspector)
      expect(beekeeper.write?).to be(true)
    end
  end
end

