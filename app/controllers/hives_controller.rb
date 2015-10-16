class HivesController < ApplicationController
  respond_to :json

  before_action :authenticate
  before_action :set_apiary, only: [:create]
  before_action :set_and_authorize_hive, only: [:show]

  def index
    @hives = Hive.where(apiary_id: params[:apiary_id])
  end

  def show
  end

  def create
    @hive = @apiary.hives.new(hive_params)
    authorize(@hive)

    if @hive.save
      render action: 'show', status: :created, location: @hive
    else
      render json: @hive.errors, status: :unprocessable_entity
    end
  end

  def update
  	@hive = Hive.find(params[:id])
    authorize(@hive)
  	@apiary = Apiary.find(params[:apiary_id])
    respond_to do |format|
      if @hive.update(hive_params)
        format.html { redirect_to [@apiary, @hive], notice: 'Hive was successfully updated.' }
        format.json { render action: 'show', status: :created, location: [@apiary, @hive] }
      else
        format.html { render action: 'edit' }
        format.json { render json: @hive.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @hive = Hive.find(params[:id])
    authorize(@hive)
    @apiary = Apiary.find(params[:apiary_id])
    @hive.destroy
    respond_to do |format|
			format.html { redirect_to apiary_url(@apiary) }
      format.json { render json: { head: :no_content } }
  	end
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
    Beekeeper.where(user_id: @user.id, apiary_id: params[:apiary_id]).first
  end
end
