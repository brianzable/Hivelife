class Api::Data::HivesController < ApplicationController
  respond_to :xml, :json
  def index
    results_city = Hive.select(:id, :name, :breed, :hive_type, :city, :state)
                  .where(donation_enabled: 1)
                  .where(fine_location_sharing: 0)
    results_exact = Hive.select(:id, :name, :breed, :hive_type, :city, :state, :latitude, :longitude)
                  .where(donation_enabled: 1)
                  .where(fine_location_sharing: 1)

    results = {exact: results_exact, address: results_city}
    respond_to do |format|
      format.json { render json: results}
      format.xml { render xml: results}
    end
  end
end
