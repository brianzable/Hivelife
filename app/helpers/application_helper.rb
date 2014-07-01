module ApplicationHelper

	# Generates a link to add nested fields to a form. Stores
	# the markup for data fields in the data-fields html attribute.
	# Taken from Railcasts #196
	def link_to_add_fields(name, f, association)
		new_object = f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			render(association.to_s.singularize, f: builder)
		end
		link_to(name, '#', class: 'add-fields', data: {id: id, fields: fields.gsub('\n', '')})
	end

	# Converts a an hour from 24 hour format to 12 hour format
	def get_hour_for_field(timestamp)
		timestamp.hour % 12
	end

	# Extracts minutes from a timestamp
	def get_minute_for_field(timestamp)
		'%02d' % timestamp.min
	end

	# Determines whether a time was in AM or PM
	def get_ampm_for_field(timestamp)
		hour = timestamp.hour
		(hour > 12) ? 'PM' : 'AM'
	end

	# Generates a rails-friendly timestamp from date and 12 hour
	# time fields.
	def create_timestamp(day, month, year, hour, minute, ampm)
		s = "#{day}-#{month}-#{year} #{hour}:#{minute}:00 #{ampm}"
		Time.zone.parse(s).strftime('%Y-%m-%d %I:%M:%S %z')
	end

	# Returns a list of states for use in forms where user's need to select
	# a state.
	def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
	end
end
