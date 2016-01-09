class InspectionEdit < ActiveRecord::Base
  belongs_to :beekeeper
  belongs_to :inspection

  def inspector_name
    beekeeper.full_name
  end
end
