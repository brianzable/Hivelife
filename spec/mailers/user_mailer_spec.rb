require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "activation_needed_email" do
    let(:mail) { UserMailer.activation_needed_email }
  end

  describe "activation_success_email" do
    let(:mail) { UserMailer.activation_success_email }
  end
end
