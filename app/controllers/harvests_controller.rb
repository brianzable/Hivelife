class HarvestsController < ApplicationController
  before_action :authenticate
  before_action :set_harvest, only: [:show, :update, :destroy]
  before_action :set_hive
  around_action :set_time_zone

  def index
    @harvests = Harvest.
        includes(harvest_edits: { beekeeper: :user }).
        where(hive_id: params[:hive_id])

    authorize(@harvests)
  end

  def show
    authorize(@harvest)
  end

  def create
    @harvest = @hive.harvests.build(harvest_params)
    authorize(@harvest)

    if @harvest.save
      @harvest.harvest_edits.create(beekeeper: @beekeeper)
      render action: 'show', status: :created, location: [@hive, @harvest]
    else
      render json: @harvest.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    authorize(@harvest)
    if @harvest.update(harvest_params)
      @harvest.harvest_edits.create(beekeeper: @beekeeper)
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

  def set_hive
    if @harvest.present?
      @hive = @harvest.hive
    else
      @hive = Hive.find(params[:hive_id])
    end
  end

  def set_harvest
    @harvest = Harvest.
      includes(harvest_edits: { beekeeper: :user }).
      where(hive_id: params[:hive_id], id: params[:id]).
      take
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
    @beekeeper = Beekeeper.where(user: @user, apiary_id: @hive.apiary_id).take
  end
end
