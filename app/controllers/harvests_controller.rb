class HarvestsController < ApplicationController
  before_action :authenticate
  before_action :set_harvest, only: [:update, :destroy]
  # before_action :set_hive, only: [:edit, :update, :create]
  # around_action :user_time_zone

  def index
    @harvests = Harvest.where(hive_id: params[:hive_id])
  end

  def show
    @harvest = Harvest.find(params[:id])
    authorize(@harvest)
  end

  def create
    @harvest = Harvest.new(harvest_params)
    @hive = Hive.find(params[:hive_id])
    authorize(@harvest)
    respond_to do |format|
      if @harvest.save
        format.html { redirect_to apiary_hive_path(@hive.apiary, @hive), notice: 'Harvest was successfully created.' }
        format.json { render action: 'show', status: :created, location: [@hive, @harvest] }
      else
        format.html { render action: 'new' }
        format.json { render json: @harvest.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize(@harvest)
    respond_to do |format|
      if @harvest.update(harvest_params)
        format.html { redirect_to apiary_hive_path(@hive.apiary, @hive), notice: 'Harvest was successfully updated.' }
        format.json { render action: 'show', status: :created, location: [@hive, @harvest] }
      else
        format.html { render action: 'edit' }
        format.json { render json: @harvest.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize(@harvest)
    @harvest.destroy
    @hive = Hive.includes(:apiary).find(params[:hive_id])
    respond_to do |format|
      format.html { redirect_to apiary_hive_path(@hive, @hive.apiary)}
      format.json { render json: { head: :no_content } }
    end
  end

private

  def set_harvest
    @harvest = Harvest.find(params[:id])
  end

  def set_hive
    @hive = Hive.includes(:apiary).find(params[:hive_id])
  end

  def harvest_params
    params[:harvest][:hive_id] = params[:hive_id]
    params.require(:harvest).permit(
      :month,
      :day,
      :year,
      :hour,
      :minute,
      :ampm,
      :honey_weight,
      :wax_weight,
      :harvested_at,
      :notes,
      :hive_id,
      :user_id
    )
  end

  def pundit_user
    apiary_id = Hive.includes(:apiary).find(params[:hive_id]).apiary.id
    Beekeeper.where(user_id: current_user.id, apiary_id: apiary_id).first
  end
end
