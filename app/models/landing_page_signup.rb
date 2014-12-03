class LandingPageSignup < ActiveRecord::Base
  validates :email_address, presence: true, uniqueness: true
  validate :validate_email_address

  def validate_email_address
    unless email_address =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
      errors.add(:base, 'Invalid email address')
    end
  end
end
