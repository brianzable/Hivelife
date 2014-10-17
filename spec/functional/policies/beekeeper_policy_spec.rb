require 'rails_helper'

describe 'BeekeeperPolicy' do
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
      permission: 'Write'
    )

    @read_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'read_user@example.com'),
      apiary: @apiary,
      permission: 'Read'
    )

    @new_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'another_user@example.com'),
      apiary: @apiary,
      permission: 'Admin'
    )
  end

  describe 'create?' do
    it 'returns false for beekeepers with read permissions' do
      policy = BeekeeperPolicy.new(@read_beekeeper, @new_beekeeper)
      expect(policy.create?).to be(false)
    end

    it 'returns false for beekeepers with write permissions' do
      policy = BeekeeperPolicy.new(@write_beekeeper, @new_beekeeper)
      expect(policy.create?).to be(false)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = BeekeeperPolicy.new(@admin_beekeeper, @new_beekeeper)
      expect(policy.create?).to be(true)
    end
  end

  describe 'update?' do
    it 'returns false for beekeepers with read permissions' do
      policy = BeekeeperPolicy.new(@read_beekeeper, @new_beekeeper)
      expect(policy.update?).to be(false)
    end

    it 'returns false for beekeepers with write permissions' do
      policy = BeekeeperPolicy.new(@write_beekeeper, @new_beekeeper)
      expect(policy.update?).to be(false)
    end

    it 'returns false or beekeepers trying to update an admin' do
      policy = BeekeeperPolicy.new(@admin_beekeeper, @new_beekeeper)
      expect(policy.update?).to be(false)
    end

    it 'returns true for beekeepers with admin permissions who are not trying to update an admin' do
      policy = BeekeeperPolicy.new(@admin_beekeeper, @write_beekeeper)
      expect(policy.update?).to be(true)
    end
  end

  describe 'destroy?' do
    it 'returns false for beekeepers with read permissions' do
      policy = BeekeeperPolicy.new(@read_beekeeper, @new_beekeeper)
      expect(policy.destroy?).to be(false)
    end

    it 'returns false for beekeepers with write permissions' do
      policy = BeekeeperPolicy.new(@write_beekeeper, @new_beekeeper)
      expect(policy.destroy?).to be(false)
    end

    it 'returns false or beekeepers trying to update an admin' do
      policy = BeekeeperPolicy.new(@admin_beekeeper, @new_beekeeper)
      expect(policy.destroy?).to be(false)
    end

    it 'returns true for beekeepers with admin permissions who are not trying to update an admin' do
      policy = BeekeeperPolicy.new(@admin_beekeeper, @write_beekeeper)
      expect(policy.destroy?).to be(true)
    end

    it 'returns true for beekeepers attemping to destroy themselves' do
      policy = BeekeeperPolicy.new(@read_beekeeper, @read_beekeeper)
      expect(policy.destroy?).to be(true)
    end
  end
end
