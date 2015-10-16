class Hive < ActiveRecord::Base
	belongs_to :apiary

	has_many :inspections, dependent: :destroy
	has_many :harvests, dependent: :destroy
end
