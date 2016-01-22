require 'rails_helper'

describe ApiaryPolicy, type: :model do
  before(:all) do
    @user = FactoryGirl.build(:user, email: 'an_email@example.com')

    @apiary = FactoryGirl.build(:apiary)

    @admin_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'admin_user@example.com'),
      apiary: @apiary
    )

    @write_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'write_user@example.com'),
      apiary: @apiary,
      role: Beekeeper::Roles::Inspector
    )

    @read_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'read_user@example.com'),
      apiary: @apiary,
      role: Beekeeper::Roles::Viewer
    )
  end
  describe 'index?' do
    it 'returns true for beekeepers with read permissions' do
      policy = ApiaryPolicy.new(@read_beekeeper, @apiary)
      expect(policy.index?).to be(true)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = ApiaryPolicy.new(@write_beekeeper, @apiary)
      expect(policy.index?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = ApiaryPolicy.new(@admin_beekeeper, @apiary)
      expect(policy.index?).to be(true)
    end
  end

  describe 'new?' do
    it 'returns true for beekeepers with read permissions' do
      policy = ApiaryPolicy.new(@read_beekeeper, @apiary)
      expect(policy.new?).to be(true)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = ApiaryPolicy.new(@write_beekeeper, @apiary)
      expect(policy.new?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = ApiaryPolicy.new(@admin_beekeeper, @apiary)
      expect(policy.new?).to be(true)
    end
  end

  describe 'create?' do
    it 'returns true for beekeepers with read permissions' do
      policy = ApiaryPolicy.new(@read_beekeeper, @apiary)
      expect(policy.create?).to be(true)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = ApiaryPolicy.new(@write_beekeeper, @apiary)
      expect(policy.create?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = ApiaryPolicy.new(@admin_beekeeper, @apiary)
      expect(policy.create?).to be(true)
    end
  end

  describe 'edit?' do
    it 'returns false for beekeepers with read permissions' do
      policy = ApiaryPolicy.new(@read_beekeeper, @apiary)
      expect(policy.edit?).to be(false)
    end

    it 'returns false for beekeepers with write permissions' do
      policy = ApiaryPolicy.new(@write_beekeeper, @apiary)
      expect(policy.edit?).to be(false)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = ApiaryPolicy.new(@admin_beekeeper, @apiary)
      expect(policy.edit?).to be(true)
    end
  end

  describe 'update?' do
    it 'returns false for beekeepers with read permissions' do
      policy = ApiaryPolicy.new(@read_beekeeper, @apiary)
      expect(policy.update?).to be(false)
    end

    it 'returns false for beekeepers with write permissions' do
      policy = ApiaryPolicy.new(@write_beekeeper, @apiary)
      expect(policy.update?).to be(false)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = ApiaryPolicy.new(@admin_beekeeper, @apiary)
      expect(policy.update?).to be(true)
    end
  end

  describe 'destroy?' do
    it 'returns false for beekeepers with read permissions' do
      policy = ApiaryPolicy.new(@read_beekeeper, @apiary)
      expect(policy.destroy?).to be(false)
    end

    it 'returns false for beekeepers with write permissions' do
      policy = ApiaryPolicy.new(@write_beekeeper, @apiary)
      expect(policy.destroy?).to be(false)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = ApiaryPolicy.new(@admin_beekeeper, @apiary)
      expect(policy.destroy?).to be(true)
    end
  end
end
