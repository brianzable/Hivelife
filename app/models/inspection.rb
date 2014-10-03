class Inspection < ActiveRecord::Base
	include ApplicationHelper
	WEATHER_CONDITIONS = [
    'Clear', 'Cloudy', 'Drizzle', 'Fair', 'Fog', 'Haze', 'Icy',
    'Light Rain', 'Mostly Cloudy', 'Overcast', 'Partly Cloudy',
		'Rain', 'Snow Showers', 'Sunny', 'Thunder Storms', 'Windy'
  ]

	attr_accessor :month, :day, :year, :hour, :minute, :ampm

	belongs_to :hive
	has_many :brood_boxes, dependent: :destroy
	has_many :honey_supers, dependent: :destroy
	has_many :diseases

	accepts_nested_attributes_for :honey_supers, allow_destroy: true
	accepts_nested_attributes_for :brood_boxes, allow_destroy: true
	accepts_nested_attributes_for :diseases, allow_destroy: true

	before_save :set_inspection_time

private
  # TODO: Figure out a better way to deal with this.
	def set_inspection_time
    unless month.blank? || day.blank? || year.blank? || hour.blank? || minute.blank? || ampm.blank?
      self.inspected_at = create_timestamp(day, month, year, hour, minute, ampm)
    end
	end
end
