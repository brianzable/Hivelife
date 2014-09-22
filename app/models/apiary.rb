class Apiary < ActiveRecord::Base
	has_many :beekeepers, dependent: :destroy
	has_many :hives, dependent: :destroy
	has_many :users, through: :beekeepers

	validates :name,
						presence: {message: 'Apiary name cannot be blank' }

	validates :zip_code,
						presence: {message: 'Zip code cannot be blank'}

	accepts_nested_attributes_for :beekeepers, allow_destroy: true

  def get_location_string
		if city.blank? || state.blank?
			return "#{self.zip_code}"
		else
			return "#{self.city}, #{self.state}"
		end
	end

  def self.for_user(user)
    self.joins(:beekeepers)
        .where(beekeepers: { user: user })
        .includes(:hives)
  end
end
