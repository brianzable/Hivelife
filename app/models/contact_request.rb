class ContactRequest < ActiveRecord::Base
  validates :name, presence: true
  validates :email_address, presence: true
  validates :subject, presence: true
  validates :message, presence: true
end
