require 'rails_helper'

describe HarvestPolicy do
  before(:all) do
    @user = FactoryGirl.build(:user, email: 'an_email@example.com')

    @apiary = FactoryGirl.build(:apiary_with_hives)

    @admin_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'admin_user@example.com'),
      apiary: @apiary
    )

    @write_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'write_user@example.com'),
      apiary: @apiary,
      permission: 'Write'
    )

    @read_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'read_user@example.com'),
      apiary: @apiary,
      permission: 'Read'
    )

    @hive = @apiary.hives.first
    @harvest = FactoryGirl.build(:harvest, hive: @hive)
  end

  describe 'show?' do
    it 'returns true for beekeepers with read permissions' do
      policy = HarvestPolicy.new(@read_beekeeper, @harvest)
      expect(policy.show?).to be(true)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = HarvestPolicy.new(@write_beekeeper, @harvest)
      expect(policy.show?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HarvestPolicy.new(@admin_beekeeper, @harvest)
      expect(policy.show?).to be(true)
    end
  end

  describe 'create?' do
    it 'returns false for beekeepers with read permissions' do
      policy = HarvestPolicy.new(@read_beekeeper, @harvest)
      expect(policy.create?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = HarvestPolicy.new(@write_beekeeper, @harvest)
      expect(policy.create?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HarvestPolicy.new(@admin_beekeeper, @harvest)
      expect(policy.create?).to be(true)
    end
  end

  describe 'update?' do
    it 'returns false for beekeepers with read permissions' do
      policy = HarvestPolicy.new(@read_beekeeper, @harvest)
      expect(policy.update?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = HarvestPolicy.new(@write_beekeeper, @harvest)
      expect(policy.update?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HarvestPolicy.new(@admin_beekeeper, @harvest)
      expect(policy.update?).to be(true)
    end
  end

  describe 'destroy?' do
    it 'returns false for beekeepers with read permissions' do
      policy = HarvestPolicy.new(@read_beekeeper, @harvest)
      expect(policy.destroy?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = HarvestPolicy.new(@write_beekeeper, @harvest)
      expect(policy.destroy?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HarvestPolicy.new(@admin_beekeeper, @harvest)
      expect(policy.destroy?).to be(true)
    end
  end
end
