class Api::Data::InspectionsController < ApplicationController
  respond_to :xml, :json
  def index
    scope = Inspection
    scope = scope.select(:id,
                         :hive_id,
                         :weather_conditions,
                         :weather_notes,
                         :notes,
                         :entrance_reducer,
                         :queen_excluder,
                         :hive_orientation,
                         :health,
                         :ventilated,
                         :inspected_at)

    scope = scope.includes(:diseases)
                 .includes(:honey_supers)
                 .includes(:brood_boxes)
                 .joins(:hive)
    scope = scope.where('hives.donation_enabled = 1')
    scope = scope.where(hive_id: params[:hive_id]) unless params[:hive_id].blank?
    scope = scope.where(entrance_reducer: params[:entrance_reducer]) unless params[:entrance_reducer].blank?
    scope = scope.where(queen_excluder: params[:queen_excluder]) unless params[:queen_excluder].blank?
    scope = scope.where(ventilation: params[:ventilation]) unless params[:ventilation].blank?
    scope = scope.where(hive_orientation: params[:hive_orientation]) unless params[:hive_orientation].blank?
    scope = scope.where(health: params[:health]) unless params[:health].blank?

    includes = {:diseases => {
                   only: [:disease_type, :treatment]
                 },
                 :honey_supers => {
                   only: [:full, :capped, :ready_for_harvest]
                 },
                 :brood_boxes => {
                   only: [:pattern,
                          :eggs_sighted,
                          :queen_sighted,
                          :queen_cells_sighted,
                          :swarm_cells_sighted,
                          :supercedure_cells_sighted,
                          :swarm_cells_capped,
                          :honey_sighted,
                          :pollen_sighted,
                          :swarm_cell_sighted]
                   }}

    respond_to do |format|
      format.json { render json: scope, include: includes}
      format.xml { render xml: scope, include: includes }
    end
  end
end
