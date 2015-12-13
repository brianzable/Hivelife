class Inspection < ActiveRecord::Base
	belongs_to :hive
	has_many :diseases

	accepts_nested_attributes_for :diseases, allow_destroy: true

  validates_presence_of :inspected_at
end
