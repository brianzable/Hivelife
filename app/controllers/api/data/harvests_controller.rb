class Api::Data::HarvestsController < ApplicationController
  def index
    scope = Harvest
    scope = scope.select(:id,
                         :hive_id,
                         :honey_weight,
                         :wax_weight,
                         :notes,
                         :harvested_at)
    scope = scope.joins(:hive)
    scope = scope.where('hives.donation_enabled = 1')
    respond_to do |format|
      format.json { render json: scope}
      format.xml { render xml: scope}
    end
  end
end
