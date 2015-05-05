class User < ActiveRecord::Base
  authenticates_with_sorcery!

  before_create :set_authentication_token

  validates :password, length: { minimum: 8 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

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
