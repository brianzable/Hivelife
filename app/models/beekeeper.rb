class Beekeeper < ActiveRecord::Base
	PERMISSIONS = [["Can View", "Read"],
								 ["Can Edit", "Write"],
								 ["Admin", "Admin"]]

	attr_accessor :email

	belongs_to :apiary
	belongs_to :user

	validates :user_id,
						presence: {message: 'User could not be found'},
						uniqueness: {scope: :apiary_id,
												 message: "User is already a beekeeper at this apiary."}

	validates :creator, presence: true

	validates :permission,
						inclusion: PERMISSIONS.map{ |key, value| value }

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
