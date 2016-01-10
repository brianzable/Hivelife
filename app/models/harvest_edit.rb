class HarvestEdit < ActiveRecord::Base
  belongs_to :beekeeper
  belongs_to :harvest

  def harvester_name
    beekeeper.full_name
  end
end
