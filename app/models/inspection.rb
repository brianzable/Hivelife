class Inspection < ActiveRecord::Base
	has_many :diseases
  has_many :inspection_edits, -> { order 'created_at ASC' }

	belongs_to :hive

	accepts_nested_attributes_for :diseases, allow_destroy: true

  validates_presence_of :inspected_at

  def last_edit
    inspection_edits.first
  end
end
