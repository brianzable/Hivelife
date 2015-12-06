class Hive < ActiveRecord::Base
	belongs_to :apiary

	has_many :inspections, dependent: :destroy
	has_many :harvests, dependent: :destroy

  def inspection_with_defaults
    inspections.first || inspections.build
  end
end
