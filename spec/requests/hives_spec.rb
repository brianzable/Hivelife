require 'rails_helper'

describe 'Hives', type: :request do
  context 'html' do
    describe '#show' do
      it 'display the hive name and a list of inspections associated with the hive'
    end

    describe '#edit' do
      it 'displays a form allowing users to edit hive information'
    end

    describe '#new' do
      it 'displays a form allowing users to create a new hive'
    end
  end

  context 'json' do
    describe '#show' do
      it 'returns a json object with hive information and a list of inspections associated with the hive'
      it 'allows users with read permission to view hive information'
      it 'allows users with write permission to view hive information'
      it 'allows users with admin permission to view hive information'
      it 'does not allow unauthorized users to view hive information'
    end

    describe '#create' do
      it 'allows users with write permission to add a hive to an apiary'
      it 'allows users with admin permission to add a hive to the apiary'
      it 'does not allow users with read permission to add a hive to an apiary'
      it 'does not allow random users to add a hive to an apiary'
    end

    describe '#update' do
      it 'allows users with write permission to edit hive information'
      it 'allows users with admin permission to edit hive information'
      it 'does not allow users with read permission to edit hive information'
      it 'does not allow random users to edit hive information'
    end

    describe '#destroy' do
      it 'allows admins to delete a hive from an apiary'
      it 'does not allow write users to delete a hive from an apiary'
      it 'does not allow read users to delete a hive from an apiary'
      it 'does not allow random users to delete a hive from an apiary'
      it 'removes all harvests associated with a hive'
      it 'removes all inspection data associated with a hive'
    end
  end
end
