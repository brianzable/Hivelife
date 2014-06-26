require 'spec_helper'
require 'rails_helper'

include Warden::Test::Helpers
Warden.test_mode!

module RequestHelpers
  def create_logged_in_user
    user = FactoryGirl.create(:user)
    sign_in(user)
    user
  end

  def confirm(user)
    user.confirmed_at = Time.now
    user.save
  end

  def sign_in(user)
    confirm user
    login_as user, scope: :user
  end

  def sign_out(user)
    logout user
  end
end
