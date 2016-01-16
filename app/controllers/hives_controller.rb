class HivesController < ApplicationController
  before_action :authenticate
  before_action :set_apiary, only: [:create]
  before_action :set_and_authorize_hive, only: [:show, :update, :destroy]
  around_action :set_time_zone

  def index
    @hives = Hive.where(apiary_id: params[:apiary_id]).order_by('name ASC')
    authorize(@hives)
  end

  def show
  end

  def create
    @hive = @apiary.hives.new(hive_params)
    authorize(@hive)

    if @hive.save
      render action: 'show', status: :created, location: @hive
    else
      render json: @hive.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    authorize(@hive)

    if @hive.update(hive_params)
      render action: 'show', status: :created, location: [@hive.apiary, @hive]
    else
      render json: @hive.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    authorize(@hive)

    @hive.destroy
    render json: { head: :no_content }
  end

  private

  def set_and_authorize_hive
    @hive = Hive.includes(:apiary, :inspections, :harvests).find(params[:id])
    authorize(@hive)
  end

  def set_apiary
    @apiary = Apiary.find(params[:apiary_id])
  end

  def hive_params
    params.require(:hive).permit(
      :name,
      :hive_type,
      :latitude,
      :longitude,
      :orientation,
      :breed,
      :comments,
      :source,
      :data_sharing,
      :exact_location_sharing
    )
  end

  def pundit_user
    @beekeeper = Beekeeper.where(user_id: @user.id, apiary_id: params[:apiary_id]).first
  end
end
