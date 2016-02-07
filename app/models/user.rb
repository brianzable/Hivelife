class User < ActiveRecord::Base
  authenticates_with_sorcery!

  before_create :set_authentication_token
  before_save :set_photo_url

  validates :password, length: { minimum: 8 }, if: :validate_password?
  validates :password, confirmation: true, if: :validate_password?
  validates :password_confirmation, presence: true, if: :validate_password?

  validates :email, uniqueness: true, presence: true

  def validate_password?
    new_record? || password.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def set_authentication_token
    return if authentication_token.present?
    self.authentication_token = generate_authentication_token
  end

  def generate_authentication_token
    SecureRandom.uuid.gsub(/\-/,'')
  end

  def set_photo_url
    md5 = Digest::MD5.hexdigest(self.email.downcase)
    self.photo_url = "http://www.gravatar.com/avatar/#{md5}?s=200"
  end
end
