class Hive < ActiveRecord::Base
	TYPES = [["Langstroth", "Langstroth"], ["Warre", "Warre"], ["Top-bar", "Top-bar"]]

	ORIENTATIONS = [["South", "S"],
									["Southwest", "SW"],
									["Southeast", "SE"],
									["West", "W"],
									["Northwest", "NW"],
									["North", "N"],
									["Northeast", "NE"],
									["East", "E"]]

	PRINT_ORIENTATIONS = {
		'S' => 'South',
		'SW' => 'Southwest',
		'SE' => 'Southeast',
		'W' => 'West',
		'NW' => 'Northwest',
		'N' => 'North',
		'NE' => 'Northeast',
		'E' => 'East'
	}

	BREEDS = [["Italian Bees", "Italian"],
						["Carniolan Bees", "Carniolan"],
						["Caucasian Bees", "Caucasian"],
						["German Black Bees", "German Black"],
						["Africanized Honey Bee", "Africanized Honey"],
						["Russian Bees", "Russian"],
						["Feral Bees", "Feral"],
						["I don't know", "I don't know"]]

	ENTRANCE_REDUCER_LARGE = 'Large'
	ENTRANCE_REDUCER_SMALL = 'Small'

	belongs_to :apiary
	belongs_to :user

	has_many :inspections
	has_many :harvests

	validates :user_id, :apiary_id,
						presence: true

	validates :hive_type,
						inclusion: TYPES.map{ |key, value| value }

	validates :breed,
						inclusion: BREEDS.map{ |key, value| value },
						allow_blank: true

	validates :orientation,
						inclusion: ORIENTATIONS.map{ |key, value| value },
						allow_blank: true

	validates :name,
						presence: {message: "Hive name can't be blank"}

	validate :validate_location

	def validate_location
		if !((self.city? && self.state?) || (self.latitude? && self.longitude?))
			errors.add(:base, 'Address or location must be set')
		end
	end

	def city_state_string
		if !(city.blank? || state.blank?)
			"#{self.city}, #{self.state}"
		end
	end

	def exact_location_string(decimal_places = 5)
		if !(latitude.blank? or longitude.blank?)
			"#{self.latitude.round(decimal_places)}, #{self.longitude.round(decimal_places)}"
		end
	end

	def get_location_string(priority = :exact)
		exact = exact_location_string
		city = city_state_string
		if priority == :exact
			return exact || city
		elsif priority == :city
			return city || exact
		end
	end

	def get_map_icon_url
		point = get_location_string
		"http://maps.googleapis.com/maps/api/staticmap?size=175x120&maptype=roadmap&zoom=18&markers=size:mid%7Ccolor:red%7C#{point}&sensor=false"
	end

	def get_falling_fruit_url
		if !(latitude.blank? or longitude.blank?)
			"https://fallingfruit.org/locations/embed?z=12&y=#{latitude}&x=#{longitude}&m=true&t=roadmap&l=false&circle=4828.032"
		else
			'https://fallingfruit.org/locations/embed?z=2&y=42.68243&x=-49.57031&m=true&t=roadmap&l=false'
		end
	end
end
