require 'spec_helper'
require 'rails_helper'

module SessionHelper
  def create_logged_in_user(options = {})
    email = options.fetch(:email, 'user@example.com')
    password = options.fetch(:password, '11111111')

    FactoryGirl.create(
      :user,
      email: email,
      password: password,
      password_confirmation: password
    )
  end
end
