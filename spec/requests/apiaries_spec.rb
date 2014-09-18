require 'rails_helper'

RSpec.describe 'Apiaries', type: :request do
  before(:each) do
    @user = create_logged_in_user
  end

  context 'html' do
    subject { page }
    describe '#index' do
      it "has title 'Hivelife | Home'" do
        visit '/'
        expect(page).to have_title('Hivelife | Home')
      end

      it 'links to apiaries#new' do
        visit authenticated_root_path
        expect(page).to have_link('+', href: new_apiary_path)
      end

      it 'displays hive count and apiary city/state' do
        apiary = FactoryGirl.create(:apiary, user_id: @user.id)
        beekeeper = FactoryGirl.create(:beekeeper,
                                        user: @user,
                                        apiary: apiary,
                                        creator: @user.id)
        visit authenticated_root_path

        expect(page).to have_selector('h3', text: '0')
        expect(page).to have_selector('h5', text: 'HIVES')
        expect(page).to have_selector('h3', text: apiary.name)
        expect(page).to have_selector('h5', text: "#{apiary.city}, #{apiary.state}")
      end

      it 'displays a hive count of two' do
        apiary_with_hives = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)
        beekeeper = FactoryGirl.create(:beekeeper,
                                        user: @user,
                                        apiary: apiary_with_hives,
                                        creator: @user.id)

        visit authenticated_root_path

        expect(page).to have_selector('h3', text: '2')
        expect(page).to have_selector('h5', text: 'HIVES')
      end
    end

    describe '#new' do
      it 'displays errors if the name and zip code are blank' do
        visit new_apiary_path

        click_button('Save')

        expect(page).to have_content('Apiary name cannot be blank')
        expect(page).to have_content('Zip code cannot be blank')
        expect(page).to_not have_content('Add Beekeeper')
      end

      it 'creates a new apiary and beekeeper when a name and zip code are given' do
        visit new_apiary_path

        fill_in('Name', with: 'My Backyard')
        fill_in('Zip code', with: '60606')

        expect { click_button('Save') }.to change{ Apiary.count }.by(1)
      end

      it 'redirects the user to the show page after successful submission' do
        visit new_apiary_path

        fill_in('Name', with: 'My Backyard')
        fill_in('Zip code', with: '60606')

        click_button('Save')

        apiary = Apiary.last
        expect(current_path).to eq(apiary_path(apiary))
      end
    end

    describe '#edit' do
      context 'Beekeeper management' do
        it 'allows an admin to manage beekeepers' do
          apiary = FactoryGirl.create(:apiary, user_id: @user.id)
          beekeeper = FactoryGirl.create(:beekeeper,
                                         user: @user,
                                         apiary: apiary,
                                         creator: @user.id)

          visit edit_apiary_path(apiary)
          expect(page).to have_content('Add Beekeeper')
        end

        it 'does not allow non-admins to manage beekeepers' do
          apiary = FactoryGirl.create(:apiary, user_id: @user.id)
          beekeeper = FactoryGirl.create(:beekeeper,
                                         permission: 'Read',
                                         user: @user,
                                         apiary: apiary,
                                         creator: @user.id)

          visit edit_apiary_path(apiary)
          expect(page).to_not have_content('Add Beekeeper')

          beekeeper.permission = 'Write'
          beekeeper.save

          visit edit_apiary_path(apiary)
          expect(page).to_not have_content('Add Beekeeper')
        end
      end
    end
  end

  context 'json' do
    describe '#index' do
      it "returns a list of the user's apiaries"
    end

    describe '#show' do
      it 'allows users who are memebers of an apiary to view apiary information'
      it 'does not allow users who are not members at an apiary to view an apiary'
      it 'contains a list of hives associated with this apiary'
    end

    describe '#create' do
      it 'creates and returns a JSON representation of the apiary'
      it 'creates a beekeeper object making the creator an admin at the new apiary'
    end

    describe '#update' do
      it 'allows the administator of an apiary to change apiary information'
      it 'does not allow users with read permissions to update an apiary'
      it 'does not allow users with write permissions to update an apiary'
      it 'does not allow administrators of other apiaries to update other apiaries'
    end

    describe '#destroy' do
      it 'allows admins at an apiary to delete an apiary'
      it 'removes all beekeepers associated with this apiary'
      it 'removes all hives associated with this apiary'
      it 'does not allow users with read permissions to destroy an apiary'
      it 'does not allow users with write permissions to destroy an apiary'
      it 'does not allow users to destroy random apiaries'
    end
  end
end
