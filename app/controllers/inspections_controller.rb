class InspectionsController < ApplicationController
  before_action :authenticate
  before_action :set_inspection, only: [:show, :update, :destroy]
  before_action :set_hive, only: [:create, :update]

  def index
    @inspections = Inspection.where(hive_id: params[:hive_id])
  end

  def show
    authorize(@inspection)
  end

  def create
    @inspection = @hive.inspections.new(inspection_params)
    authorize(@inspection)

    if @inspection.save
      render action: 'show', status: :created, location: [@hive, @inspection]
    else
      render json: @inspection.errors, status: :unprocessable_entity
    end
  end

  def update
    authorize(@inspection)
    if @inspection.update(inspection_params)
      render action: 'show', status: :created, location: [@hive, @inspection]
    else
      render json: @inspection.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize(@inspection)
    @inspection.destroy

    render json: { head: :no_content }
  end

  private

  def set_inspection
    @inspection = Inspection.find(params[:id])
  end

  def set_hive
    @hive = Hive.includes(:apiary).find(params[:hive_id])
  end

  def inspection_params
    params.require(:inspection).permit(
      :inspected_at,
      :temperature,
      :weather_conditions,
      :weather_notes,
      :notes,
      :ventilated,
      :entrance_reducer,
      :queen_excluder,
      :hive_temperament,
      :hive_orientation,
      :health,
      :brood_pattern,
      :eggs_sighted,
      :queen_sighted,
      :queen_cells_sighted,
      :honey_sighted,
      :pollen_sighted,
      :swarm_cells_sighted,
      :supersedure_cells_sighted,
      :swarm_cells_capped,
      :diseases_attributes => disease_attributes
    )
  end

  def disease_attributes
    [:id, :disease_type, :treatment, :notes, :_destroy]
  end

  def pundit_user
    apiary = Hive.includes(:apiary).find(params[:hive_id]).apiary
    Beekeeper.where(user: @user, apiary: apiary).first
  end
end
