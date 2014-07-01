class Beekeeper < ActiveRecord::Base
	PERMISSIONS = [["Can View", "Read"],
								 ["Can Edit", "Write"],
								 ["Admin", "Admin"]]

	# Create a virtual email attribute. This is not stored in the database.
	attr_accessor :email

	belongs_to :apiary
	belongs_to :user

	# A user must be included in a beekeeper entry.
	# An apiary can only have one instance of a specific user.
	validates :user_id,
						presence: {message: 'User could not be found'},
						uniqueness: {scope: :apiary_id,
												 message: "User is already a beekeeper at this apiary."}

	# Keep track of the person who added this beekeeper to the apiary.
	validates :creator, presence: true

	# A user must have a permission.
	# The permission may is limited to read, write, or admin.
	validates :permission,
						presence: true,
						inclusion: PERMISSIONS.map{ |key, value| value }

	# Apiary id is required
	validates :apiary_id, presence: true

	# Returns a list of beekeepers associated with the specified apiary id
	def self.for_apiary(apiary_id)
		self.where(apiary_id: apiary_id).includes(:user)
	end

	# Returns the permission specified for a user at an apiary
	def self.permission_for(user_id, apiary_id)
		beekeeper = self.where('user_id = ? AND apiary_id = ?', user_id, apiary_id).first
		return beekeeper.permission unless beekeeper.nil?
	end
end
