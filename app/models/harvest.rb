class Harvest < ActiveRecord::Base
	include ApplicationHelper
	attr_accessor :month, :day, :year, :hour, :minute, :ampm
	belongs_to :hive
	belongs_to :user

	before_save :set_harvest_time

private

	def set_harvest_time
		self.harvested_at = create_timestamp(day, month, year, hour, minute, ampm)
	end

end
