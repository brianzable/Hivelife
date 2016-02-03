class Harvest < ActiveRecord::Base
  has_many :harvest_edits, -> { order 'created_at ASC' }, dependent: :destroy

	belongs_to :hive, counter_cache: true

  validates_presence_of :harvested_at

  def last_edit
    harvest_edits.last
  end
end
