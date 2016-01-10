class Harvest < ActiveRecord::Base
  has_many :harvest_edits, -> { order 'created_at ASC' }

	belongs_to :hive

  validates_presence_of :harvested_at

  def last_edit
    harvest_edits.last
  end
end
