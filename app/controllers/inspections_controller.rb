class InspectionsController < ApplicationController
  before_action :authenticate
  before_action :set_inspection, only: [:edit, :update, :destroy]
  # before_action :set_hive, only: [:edit, :update, :create]
  # around_action :user_time_zone

  def index
    @inspections = Inspection.where(hive_id: params[:hive_id])
  end

  def show
    @inspection = Inspection.includes(:brood_boxes, :honey_supers).find(params[:id])
    authorize(@inspection)
  end

  def create
    @inspection = Inspection.new(inspection_params)
    authorize(@inspection)
    respond_to do |format|
      if @inspection.save
        format.html { redirect_to apiary_hive_path(@hive.apiary, @hive), notice: 'inspection was successfully created.' }
        format.json { render action: 'show', status: :created, location: [@hive, @inspection] }
      else
        format.html { render action: 'new' }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize(@inspection)
    respond_to do |format|
      if @inspection.update(inspection_params)
        format.html { redirect_to [@hive, @inspection], notice: 'Inspection was successfully updated.' }
        format.json { render action: 'show', status: :created, location: [@hive, @inspection] }
      else
        format.html { render action: 'edit' }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize(@inspection)
    @inspection.destroy
    respond_to do |format|
      format.html { redirect_to hive_inspections_url }
      format.json { render json: { head: :no_content }}
    end
  end

private

  def set_inspection
    @inspection = Inspection.find(params[:id])
  end

  def set_hive
    @hive = Hive.includes(:apiary).find(params[:hive_id])
  end

  def inspection_params
    params[:inspection][:hive_id] = params[:hive_id]
    params.require(:inspection).permit(
      :month,
      :day,
      :year,
      :hour,
      :minute,
      :ampm,
      :temperature,
      :weather_conditions,
      :weather_notes,
      :ventilated,
      :entrance_reducer,
      :entrance_reducer_size,
      :queen_excluder,
      :hive_orientation,
      :flight_pattern,
      :notes,
      :hive_id,
      :health,
      :honey_supers_attributes => honey_super_attributes,
      :brood_boxes_attributes => brood_box_attributes,
      :diseases_attributes => disease_attributes
    )
  end

  def honey_super_attributes
    [:id, :ready_for_harvest, :full, :capped, :_destroy]
  end

  def brood_box_attributes
    [
      :id,
      :pattern,
      :eggs_sighted,
      :queen_sighted,
      :queen_cells_sighted,
      :honey_sighted,
      :pollen_sighted,
      :swarm_cells_sighted,
      :supersedure_cells_sighted,
      :swarm_cells_capped,
      :_destroy
    ]
  end

  def disease_attributes
    [:disease_type, :treatment, :_destroy]
  end

  def pundit_user
    apiary_id = Hive.includes(:apiary).find(params[:hive_id]).apiary.id
    Beekeeper.where(
      user_id: current_user.id,
      apiary_id: apiary_id
    ).first
  end
end
