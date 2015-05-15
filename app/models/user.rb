class User < ActiveRecord::Base
  authenticates_with_sorcery!

  before_create :set_authentication_token

  validates :password, length: { minimum: 8 }, allow_blank: true
  validates :password, confirmation: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  validates :email, uniqueness: true

private

  def set_authentication_token
    return if authentication_token.present?
    self.authentication_token = generate_authentication_token
  end

  def generate_authentication_token
    SecureRandom.uuid.gsub(/\-/,'')
  end
end
