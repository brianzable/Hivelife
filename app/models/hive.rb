class Hive < ActiveRecord::Base
	belongs_to :apiary

	has_many :inspections, -> { order 'inspected_at DESC' }, dependent: :destroy
	has_many :harvests, -> { order 'harvested_at'}, dependent: :destroy

  attr_writer :latitude, :longitude
  before_save :set_coordinates

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

  def harvest_with_defaults
    harvests.first || harvests.build
  end

  def latitude
    if coordinates.present?
      coordinates.y
    else
      @latitude
    end
  end

  def longitude
    if coordinates.present?
      coordinates.x
    else
      @longitude
    end
  end

  private

  def set_coordinates
    self.coordinates = "POINT(#{longitude} #{latitude})"
  end
end
