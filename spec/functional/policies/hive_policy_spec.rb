require 'rails_helper'

describe HivePolicy, type: :model do
  before(:all) do
    @user = FactoryGirl.build(:user, email: 'an_email@example.com')

    @apiary = FactoryGirl.build( :apiary_with_hives)

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

    @hive = @apiary.hives.first
  end

  describe 'show?' do
    it 'returns true for beekeepers with read permissions' do
      policy = HivePolicy.new(@read_beekeeper, @hive)
      expect(policy.show?).to be(true)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = HivePolicy.new(@write_beekeeper, @hive)
      expect(policy.show?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HivePolicy.new(@admin_beekeeper, @hive)
      expect(policy.show?).to be(true)
    end
  end

  describe 'create?' do
    it 'returns false for beekeepers with read permissions' do
      policy = HivePolicy.new(@read_beekeeper, @hive)
      expect(policy.create?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = HivePolicy.new(@write_beekeeper, @hive)
      expect(policy.create?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HivePolicy.new(@admin_beekeeper, @hive)
      expect(policy.create?).to be(true)
    end
  end

  describe 'update?' do
    it 'returns false for beekeepers with read permissions' do
      policy = HivePolicy.new(@read_beekeeper, @hive)
      expect(policy.update?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = HivePolicy.new(@write_beekeeper, @hive)
      expect(policy.update?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HivePolicy.new(@admin_beekeeper, @hive)
      expect(policy.update?).to be(true)
    end
  end

  describe 'destroy?' do
    it 'returns false for beekeepers with read permissions' do
      policy = HivePolicy.new(@read_beekeeper, @hive)
      expect(policy.destroy?).to be(false)
    end

    it 'returns false for beekeepers with write permissions' do
      policy = HivePolicy.new(@write_beekeeper, @hive)
      expect(policy.destroy?).to be(false)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = HivePolicy.new(@admin_beekeeper, @hive)
      expect(policy.destroy?).to be(true)
    end
  end
end

