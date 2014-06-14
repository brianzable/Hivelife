class Apiary < ActiveRecord::Base
	has_many :beekeepers
	has_many :hives
	has_many :users, through: :beekeepers

	validates :name,
						presence: {message: 'Apiary name cannot be blank' }

	validates :zip_code,
						presence: {message: 'Zip code cannot be blank'}

	def get_location_string
		if city.blank? || state.blank?
			return "#{self.zip_code}"
		else
			return "#{self.city}, #{self.state}"
		end
	end
end
