class Inspection < ActiveRecord::Base
	has_many :diseases, dependent: :destroy
  has_many :inspection_edits, -> { order 'created_at ASC' }, dependent: :destroy

	belongs_to :hive, counter_cache: true

  VALID_WEATHER_CONDITIONS = [
    'Sunny',
    'Clear',
    'Partly Sunny',
    'Mostly Sunny',
    'Partly Cloudy',
    'Mostly Cloudy',
    'Cloudy',
    'Overcast',
    'Chance of Rain',
    'Chance of Snow',
    'Chance of Storm',
    'Dust',
    'Flurries',
    'Fog',
    'Freezing Drizzle',
    'Hail',
    'Haze',
    'Icy',
    'Light Rain',
    'Light Snow',
    'Mist',
    'Rain and Snow',
    'Rain',
    'Scattered Showers',
    'Scattered Thunderstorms',
    'Showers',
    'Sleet',
    'Smoke',
    'Snow Showers',
    'Snow',
    'Storm',
    'Thunderstorm'
  ]

	accepts_nested_attributes_for :diseases, allow_destroy: true

  validates_presence_of :inspected_at
  validates :weather_conditions, inclusion: VALID_WEATHER_CONDITIONS, allow_blank: true

  def last_edit
    inspection_edits.first
  end
end
