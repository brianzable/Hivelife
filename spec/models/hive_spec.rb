require 'rails_helper'

RSpec.describe Hive, type: :model do
  describe 'validations' do
    context 'latitude' do
      it 'must be present' do
        hive = Hive.new(name: 'Hive 1', longitude: 100)

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Latitude can't be blank")
      end

      it 'must be greater than -90' do
        hive = Hive.new(name: 'Hive 1', latitude: -100, longitude: 100)

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Latitude must be greater than or equal to -90")
      end

      it 'must be less than 90' do
        hive = Hive.new(name: 'Hive 1', latitude: 100, longitude: 100)

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Latitude must be less than or equal to 90")
      end

      it 'must be numeric' do
        hive = Hive.new(name: 'Hive 1', latitude: 'string', longitude: 100)

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Latitude is not a number")
      end
    end

    context 'longitude' do
      it 'must be present' do
        hive = Hive.new(name: 'Hive 1', latitude: 0)

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Longitude can't be blank")
      end

      it 'must be greater than -180' do
        hive = Hive.new(name: 'Hive 1', latitude: 0, longitude: -180.1)

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Longitude must be greater than or equal to -180")
      end

      it 'must be less than 180' do
        hive = Hive.new(name: 'Hive 1', latitude: 100, longitude: 180.001)

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Longitude must be less than or equal to 180")
      end

      it 'must be numeric' do
        hive = Hive.new(name: 'Hive 1', latitude: 0, longitude: 'string')

        expect(hive).to_not be_valid
        expect(hive.errors.full_messages).to include("Longitude is not a number")
      end
    end
  end
end
