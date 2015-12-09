class Hive < ActiveRecord::Base
	belongs_to :apiary

	has_many :inspections, dependent: :destroy
	has_many :harvests, dependent: :destroy

  validates_presence_of :name

  validates :latitude,
    presence: true,
    numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }

  validates :longitude,
    presence: true,
    numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  def inspection_with_defaults
    inspections.first || inspections.build
  end
end
