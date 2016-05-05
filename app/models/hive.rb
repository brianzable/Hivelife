class Hive < ActiveRecord::Base
  attr_writer :latitude, :longitude

	belongs_to :apiary, counter_cache: true

	has_many :inspections, -> { order 'inspected_at DESC' }, dependent: :destroy
	has_many :harvests, -> { order 'harvested_at'}, dependent: :destroy

  before_save :set_coordinates

  VALID_HIVE_TYPES = ['Langstroth', 'Top-Bar', 'Warre', 'British National', 'Slovenian AZ', 'Other']
  VALID_BREEDS = ['Italian', 'Russian', 'German', 'Carniolan', 'Caucasian', 'Buckfast', 'Other']
  VALID_SOURCES = ['Package', 'Nuc', 'Swarm', 'Split', 'Removal', 'Other']
  VALID_ORIENTATIONS = ['North', 'North East', 'East', 'South East', 'South', 'South West', 'West', 'North West']

  validates_presence_of :name

  validates :hive_type, inclusion: VALID_HIVE_TYPES, allow_blank: true
  validates :breed, inclusion: VALID_BREEDS, allow_blank: true
  validates :source, inclusion: VALID_SOURCES, allow_blank: true
  validates :orientation, inclusion: VALID_ORIENTATIONS, allow_blank: true

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
