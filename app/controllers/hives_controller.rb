class HivesController < ApplicationController
  before_action :authenticate_user!
  around_filter :user_time_zone
  before_action do |c|
    c.verify_beekeeper(params[:apiary_id], get_permission_for_action)
  end

  # GET /hives
  # GET /hives.json
  def index
  end

  # GET /hives/1
  # GET /hives/1.json
  def show
  	@hive = Hive.includes(:apiary).find(params[:id])
  	@inspections = Inspection.where(hive_id: params[:id]).order('inspected_at DESC').to_a
    @harvests = Harvest.where(hive_id: params[:id]).order('harvested_at DESC').to_a
    permission = Beekeeper.permission_for(current_user.id, params[:apiary_id])
    @can_write = can_perform_action?(permission, 'Write')
  end

  # GET /hives/new
  def new
    @hive = Hive.new
    @apiary = Apiary.find(params[:apiary_id])
  end

  # GET /hives/1/edit
  def edit
  	@hive = Hive.find(params[:id])
  	@apiary = Apiary.find(params[:apiary_id])
  end

  # POST /hives
  # POST /hives.json
  def create
    params[:hive][:apiary_id] = params[:apiary_id]
    @hive = Hive.new(hive_params)
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

  # PATCH/PUT /hives/1
  # PATCH/PUT /hives/1.json
  def update
  	@hive = Hive.find(params[:id])
  	@apiary = Apiary.find(params[:apiary_id])
    respond_to do |format|
      if @hive.update(hive_params)
        format.html { redirect_to [@apiary, @hive], notice: 'Hive was successfully updated.' }
        format.json { head :no_content }
      else
        puts @hive.errors.full_messages
        format.html { render action: 'edit' }
        format.json { render json: @hive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hives/1
  # DELETE /hives/1.json
  def destroy
    @hive.destroy
    respond_to do |format|
      format.html { redirect_to hives_url }
      format.json  { render json: {url => root_url }, status: :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hive
      @hive = Hive.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def hive_params
      params[:hive][:user_id] = current_user.id
      params.require(:hive).permit(:name,
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
      														 :donation_enabled,
      														 :fine_location_sharing,
      														 :apiary_id,
                                   :user_id)
    end
end
