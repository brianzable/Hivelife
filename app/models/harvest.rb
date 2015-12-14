class Harvest < ActiveRecord::Base
	belongs_to :hive

  validates_presence_of :harvested_at
end
