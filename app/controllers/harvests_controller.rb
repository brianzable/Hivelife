class HarvestsController < ApplicationController
  before_action :authenticate
  before_action :set_harvest, only: [:show, :update, :destroy]
  before_action :set_hive, only: [:update, :create]

  def index
    @harvests = Harvest.where(hive_id: params[:hive_id])
  end

  def show
    authorize(@harvest)
  end

  def create
    @harvest = @hive.harvests.new(harvest_params)
    authorize(@harvest)

    if @harvest.save
      render action: 'show', status: :created, location: [@hive, @harvest]
    else
      render json: @harvest.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    authorize(@harvest)
    if @harvest.update(harvest_params)
      render action: 'show', status: :created, location: [@hive, @harvest]
    else
      render json: @harvest.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    authorize(@harvest)
    @harvest.destroy
    render json: { head: :no_content }
  end

  private

  def set_harvest
    @harvest = Harvest.find(params[:id])
  end

  def set_hive
    @hive = Hive.includes(:apiary).find(params[:hive_id])
  end

  def harvest_params
    params.require(:harvest).permit(
      :honey_weight,
      :honey_weight_units,
      :wax_weight,
      :wax_weight_units,
      :harvested_at,
      :notes
    )
  end

  def pundit_user
    apiary_id = Hive.includes(:apiary).find(params[:hive_id]).apiary.id
    Beekeeper.where(user_id: @user.id, apiary_id: apiary_id).first
  end
end
