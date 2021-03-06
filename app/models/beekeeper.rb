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

  delegate :full_name, to: :user

	validates :user_id,
    presence: { message: 'could not be found' },
		uniqueness: { scope: :apiary_id, message: "is already a beekeeper at this apiary." }

	validates :role, inclusion: VALID_ROLES

	validates :apiary_id, presence: true

	def admin?
		role == Roles::Admin
	end

	def read?
		(role == Roles::Viewer) || write?
	end

	def write?
		(role == Roles::Inspector) || admin?
	end

	def self.for_apiary(apiary_id)
		self.where(apiary_id: apiary_id).includes(:user)
	end
end
