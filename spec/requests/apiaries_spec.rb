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
    before(:each) do
      @http_headers = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    describe '#index' do
      it "returns a list of the user's apiaries" do
        apiary_with_hives = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)
        another_apiary_with_hives = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary_with_hives,
          user: @user,
          creator: @user.id
        )

        FactoryGirl.create(
          :beekeeper,
          apiary: another_apiary_with_hives,
          user: @user,
          creator: @user.id
        )

        get(authenticated_root_path, format: :json)
        apiaries = JSON.parse(response.body)

        expect(apiaries.count).to be(2)

        first_apiary = apiaries[0]
        expect(first_apiary["id"]).to eq(apiary_with_hives.id)
        expect(first_apiary["name"]).to eq(apiary_with_hives.name)
        expect(first_apiary["photo_url"]).to eq(apiary_with_hives.photo_url)
        expect(first_apiary["city"]).to eq(apiary_with_hives.city)
        expect(first_apiary["state"]).to eq(apiary_with_hives.state)
        expect(first_apiary["zip_code"]).to eq(apiary_with_hives.zip_code)

        first_apiary_hives = first_apiary["hives"]
        expect(first_apiary_hives.count).to be(2)
        expect(first_apiary_hives[0]["id"]).to_not be_nil
        expect(first_apiary_hives[0]["name"]).to_not be_nil

        second_apiary = apiaries[1]
        expect(second_apiary["id"]).to eq(another_apiary_with_hives.id)

        second_apiary_hives = second_apiary["hives"]
        expect(second_apiary_hives.count).to be(2)
      end
    end

    describe '#show' do
      it 'allows users who are memeber of an apiary to view apiary information' do
        apiary_with_hives = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary_with_hives,
          user: @user,
          creator: @user.id
        )

        get(apiary_path(apiary_with_hives), format: :json)

        apiary = JSON.parse(response.body)

        expect(apiary["id"]).to eq(apiary_with_hives.id)
        expect(apiary["name"]).to eq(apiary_with_hives.name)
        expect(apiary["photo_url"]).to eq(apiary_with_hives.photo_url)
        expect(apiary["city"]).to eq(apiary_with_hives.city)
        expect(apiary["state"]).to eq(apiary_with_hives.state)
        expect(apiary["zip_code"]).to eq(apiary_with_hives.zip_code)

        hives = apiary["hives"]
        expect(hives.count).to be(2)
        expect(hives[0]["id"]).to_not be_nil
        expect(hives[0]["name"]).to_not be_nil
      end

      it 'does not allow users who are not members at an apiary to view an apiary' do
        apiary_with_hives = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        get(apiary_path(apiary_with_hives), format: :json)
        expect(response.code).to eq("401")

        parsed_body = JSON.parse(response.body)
        expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end

      it 'contains a list of hives associated with this apiary' do
        apiary_with_hives = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary_with_hives,
          user: @user,
          creator: @user.id
        )

        get(apiary_path(apiary_with_hives), format: :json)
        apiary = JSON.parse(response.body)

        hives = apiary["hives"]
        expect(hives.count).to be(2)
        expect(hives[0]["id"]).to_not be_nil
        expect(hives[0]["name"]).to_not be_nil
      end
    end

    describe '#create' do
      it 'creates and returns a JSON representation of the apiary' do
        payload = {
          name: 'New Apiary',
          zip_code: '60606'
        }.to_json

        expect do
          post(apiaries_path, payload, @http_headers)

          parsed_body = JSON.parse(response.body)

          expect(parsed_body["id"]).to_not be_nil
          expect(parsed_body["zip_code"]).to eq("60606")
          expect(parsed_body["photo_url"]).to_not be_nil
        end.to change { Apiary.count }
      end

      it 'returns a JSON representation of validation errors when not given required data' do
        payload = {
          zip_code: '60606'
        }.to_json

        expect do
          post(apiaries_path, payload, @http_headers)
          parsed_body = JSON.parse(response.body)

          expect(parsed_body["name"].first).to eq("Apiary name cannot be blank")
        end.to_not change { Apiary.count }
      end

      it 'creates a beekeeper object making the creator an admin at the new apiary' do
        payload = {
          name: 'New Apiary',
          zip_code: '60606'
        }.to_json

        expect(Beekeeper.find_by_user_id(@user.id)).to be_nil

        post(apiaries_path, payload, @http_headers)
        parsed_body = JSON.parse(response.body)

        beekeeper = Beekeeper.last
        expect(beekeeper.permission).to eq('Admin')
        expect(beekeeper.apiary_id).to eq(parsed_body['id'])
      end
    end

    describe '#update' do
      it 'allows an administator of an apiary to change apiary information' do
        payload = {
          city: 'Chicago'
        }.to_json

        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: @user,
          creator: @user.id
        )

        put(apiary_path(apiary), payload, @http_headers)
        parsed_body = JSON.parse(response.body)

        expect(parsed_body["city"]).to eq("Chicago")
      end

      it 'does not allow users with read permissions to update an apiary' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: unauthorized_user,
          creator: unauthorized_user.id,
          permission: 'Read'
        )

        payload = {
          city: 'Chicago'
        }.to_json

        put(apiary_path(apiary), payload, @http_headers)
        parsed_body = JSON.parse(response.body)

        expect(response.code).to eq("401")
        expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end

      it 'does not allow users with write permissions to update an apiary' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: unauthorized_user,
          creator: unauthorized_user.id,
          permission: 'Write'
        )

        payload = {
          city: 'Chicago'
        }.to_json

        put(apiary_path(apiary), payload, @http_headers)
        parsed_body = JSON.parse(response.body)

        expect(response.code).to eq("401")
        expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end

      it 'does not allow administrators of other apiaries to update other apiaries' do
        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: @user,
          creator: @user.id
        )

        another_apiary = FactoryGirl.create(:apiary)

        payload = {
          city: 'Chicago'
        }.to_json

        put(apiary_path(another_apiary), payload, @http_headers)
        parsed_body = JSON.parse(response.body)

        expect(response.code).to eq("401")
        expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
      end
    end

    describe '#destroy' do
      it 'allows admins at an apiary to delete an apiary' do
        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: @user,
          creator: @user.id
        )

        expect do
          delete(apiary_path(apiary), nil, @http_headers)

          parsed_body = JSON.parse(response.body)
          expect(response.code).to eq('200')
          expect(parsed_body["head"]).to eq("no_content")
        end.to change{ Apiary.count }
      end

      it 'removes all beekeepers associated with this apiary' do
        apiary = FactoryGirl.create(:apiary)

        beekeeper = FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: @user,
          creator: @user.id
        )

        expect do
          delete(apiary_path(apiary), nil, @http_headers)
          expect(response.code).to eq('200')
          expect{@user.reload}.to_not raise_error
        end.to change{ Beekeeper.count }
      end

      it 'removes all hives associated with this apiary' do
        apiary = FactoryGirl.create(:apiary_with_hives, user_id: @user.id)

        beekeeper = FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: @user,
          creator: @user.id
        )

        expect do
          delete(apiary_path(apiary), nil, @http_headers)
          expect(response.code).to eq('200')
        end.to change{ Hive.count }
      end

      it 'does not allow users with read permissions to destroy an apiary' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: unauthorized_user,
          creator: unauthorized_user.id,
          permission: 'Read'
        )

        expect do
          delete(apiary_path(apiary), nil, @http_headers)
          parsed_body = JSON.parse(response.body)

          expect(response.code).to eq("401")
          expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
        end.to_not change { Apiary.count }
      end

      it 'does not allow users with write permissions to destroy an apiary' do
        unauthorized_user = create_logged_in_user(email: 'another_user@example.com')

        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: unauthorized_user,
          creator: unauthorized_user.id,
          permission: 'Read'
        )

        expect do
          delete(apiary_path(apiary), nil, @http_headers)
          parsed_body = JSON.parse(response.body)

          expect(response.code).to eq("401")
          expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
        end.to_not change { Apiary.count }
      end

      it 'does not allow users to destroy random apiaries' do
        apiary = FactoryGirl.create(:apiary)

        FactoryGirl.create(
          :beekeeper,
          apiary: apiary,
          user: @user,
          creator: @user.id
        )

        another_apiary = FactoryGirl.create(:apiary)
        expect do
          delete(apiary_path(another_apiary), nil, @http_headers)
          parsed_body = JSON.parse(response.body)

          expect(response.code).to eq("401")
          expect(parsed_body["error"]).to eq("You are not authorized to perform this action.")
        end.to_not change{ Apiary.count }
      end
    end
  end
end
