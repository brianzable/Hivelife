require 'rails_helper'

describe InspectionPolicy do
  before(:all) do
    @user = FactoryGirl.build(:user, email: 'an_email@example.com')

    @apiary = FactoryGirl.build(
      :apiary_with_hives,
      user_id: @user.id
    )

    @admin_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'admin_user@example.com'),
      apiary: @apiary,
      creator: @user.id
    )

    @write_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'write_user@example.com'),
      apiary: @apiary,
      creator: @user.id,
      permission: 'Write'
    )

    @read_beekeeper = FactoryGirl.build(
      :beekeeper,
      user: FactoryGirl.build(:user, email: 'read_user@example.com'),
      apiary: @apiary,
      creator: @user.id,
      permission: 'Read'
    )

    @hive = @apiary.hives.first
    @inspection = FactoryGirl.build(:inspection, hive: @hive)
  end

  describe 'show?' do
    it 'returns true for beekeepers with read permissions' do
      policy = InspectionPolicy.new(@read_beekeeper, @inspection)
      expect(policy.show?).to be(true)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = InspectionPolicy.new(@write_beekeeper, @inspection)
      expect(policy.show?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = InspectionPolicy.new(@admin_beekeeper, @inspection)
      expect(policy.show?).to be(true)
    end
  end

  describe 'create?' do
    it 'returns false for beekeepers with read permissions' do
      policy = InspectionPolicy.new(@read_beekeeper, @inspection)
      expect(policy.create?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = InspectionPolicy.new(@write_beekeeper, @inspection)
      expect(policy.create?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = InspectionPolicy.new(@admin_beekeeper, @inspection)
      expect(policy.create?).to be(true)
    end
  end

  describe 'update?' do
    it 'returns false for beekeepers with read permissions' do
      policy = InspectionPolicy.new(@read_beekeeper, @inspection)
      expect(policy.update?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = InspectionPolicy.new(@write_beekeeper, @inspection)
      expect(policy.update?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = InspectionPolicy.new(@admin_beekeeper, @inspection)
      expect(policy.update?).to be(true)
    end
  end

  describe 'destroy?' do
    it 'returns false for beekeepers with read permissions' do
      policy = InspectionPolicy.new(@read_beekeeper, @inspection)
      expect(policy.destroy?).to be(false)
    end

    it 'returns true for beekeepers with write permissions' do
      policy = InspectionPolicy.new(@write_beekeeper, @inspection)
      expect(policy.destroy?).to be(true)
    end

    it 'returns true for beekeepers with admin permissions' do
      policy = InspectionPolicy.new(@admin_beekeeper, @inspection)
      expect(policy.destroy?).to be(true)
    end
  end
end


