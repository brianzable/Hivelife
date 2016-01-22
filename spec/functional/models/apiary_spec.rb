require 'rails_helper'

describe Apiary, type: :model do
  describe 'self.for_user' do
    it 'returns a list apiaries a user is a member of' do
      user = FactoryGirl.create(:user)

      apiary_with_hives = FactoryGirl.create(:apiary_with_hives)
      another_apiary_with_hives = FactoryGirl.create(:apiary_with_hives)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary_with_hives,
        user: user
      )

      FactoryGirl.create(
        :beekeeper,
        apiary: another_apiary_with_hives,
        user: user
      )

      results = Apiary.for_user(user)
      expect(results.size).to be(2)
    end

    it 'also includes all hives belonging to each apiary' do
      user = FactoryGirl.create(:user)

      apiary_with_hives = FactoryGirl.create(:apiary_with_hives)
      another_apiary_with_hives = FactoryGirl.create(:apiary_with_hives)

      FactoryGirl.create(
        :beekeeper,
        apiary: apiary_with_hives,
        user: user
      )

      FactoryGirl.create(
        :beekeeper,
        apiary: another_apiary_with_hives,
        user: user
      )

      results = Apiary.for_user(user)

      expect(results.size).to be(2)
      expect(results[0].hives.size).to be(20)
      expect(results[1].hives.size).to be(20)
    end

    it 'returns an empty array if the user is not a member at any apiaries' do
      user = FactoryGirl.create(:user)

      results = Apiary.for_user(user)
      expect(results).to eq([])
    end
  end
end
