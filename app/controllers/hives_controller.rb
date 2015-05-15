class HivesController < ApplicationController
  before_action :authenticate_user!
  around_filter :user_time_zone

  def show
    @hive = Hive.includes(:apiary, :inspections, :harvests).find(params[:id])
    authorize(@hive)
  end

  def new
    @hive = Hive.new
    @apiary = Apiary.find(params[:apiary_id])
  end

  def edit
  	@hive = Hive.find(params[:id])
  	@apiary = Apiary.find(params[:apiary_id])
  end

  def create
    params[:hive][:apiary_id] = params[:apiary_id]

    @hive = Hive.new(hive_params)
		authorize(@hive)

    @apiary = Apiary.find(params[:apiary_id])
    respond_to do |format|
      if @hive.save
        format.html { redirect_to [@apiary, @hive], notice: 'Hive was successfully created.' }
        format.json { render action: 'show', status: :created, location: @hive }
      else
        format.html { render action: 'new' }
        format.json { render json: @hive.errors, status: :unprocessable_entity }
      end
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

  def set_hive
    @hive = Hive.find(params[:id])
  end

  def hive_params
    params.require(:hive).permit(
      :name,
      :hive_type,
      :street_address,
      :city,
      :zip_code,
      :state,
      :latitude,
      :longitude,
      :photo_url,
      :ventilated,
      :entrance_reducer,
      :entrance_reducer_size,
      :queen_excluder,
      :orientation,
      :breed,
      :public,
      :fine_location_sharing,
      :apiary_id
    )
  end

  def pundit_user
    Beekeeper.where(
      user_id: current_user.id,
      apiary_id: params[:apiary_id]
    ).first
  end
end
