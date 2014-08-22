require 'spec_helper'
require 'rails_helper'

include Warden::Test::Helpers
Warden.test_mode!

module RequestHelpers
  def create_logged_in_user(options = {})
    options[:email] = 'user@example.com' unless options.has_key?(:email)
    user = FactoryGirl.create(:user, email: options[:email])
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
