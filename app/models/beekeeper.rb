class Beekeeper < ActiveRecord::Base
  module Roles
    Viewer = 'Viewer'
    Inspector = 'Inspector'
    Admin = 'Admin'
  end

  VALID_ROLES = [Roles::Viewer, Roles::Inspector, Roles::Admin]

	attr_accessor :email

	belongs_to :apiary
	belongs_to :user

	validates :user_id,
    presence: { message: 'could not be found' },
		uniqueness: { scope: :apiary_id, message: "is already a beekeeper at this apiary." }

	validates :permission, inclusion: VALID_ROLES

	validates :apiary_id, presence: true

	def admin?
		self.permission == 'Admin'
	end

	def read?
		(self.permission == 'Read') || self.write?
	end

	def write?
		(self.permission == 'Write') || self.admin?
	end

	def self.for_apiary(apiary_id)
		self.where(apiary_id: apiary_id).includes(:user)
	end
end
