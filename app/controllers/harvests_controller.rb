class HarvestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_harvest, only: [:edit, :update, :destroy]
  before_action :set_hive, only: [:edit, :update, :create]
  around_filter :user_time_zone
  before_action do |c|
    h = Hive.find(params[:hive_id])
    c.verify_beekeeper(h.apiary_id, get_permission_for_action)
  end
  # GET /harvests
  # GET /harvests.json
  def index
    @harvests = Harvest.all
  end

  # GET /harvests/1
  # GET /harvests/1.json
  def show
    @harvest = Harvest.find(params[:id])
  end

  # GET /harvests/new
  def new
    @hive = Hive.find(params[:hive_id])
    @harvest = Harvest.new
  end

  # GET /harvests/1/edit
  def edit
  end

  # POST /harvests
  # POST /harvests.json
  def create
    @harvest = Harvest.new(harvest_params)

    respond_to do |format|
      if @harvest.save
        format.html { redirect_to apiary_hive_path(@hive.apiary, @hive), notice: 'Harvest was successfully created.' }
        format.json { render action: 'show', status: :created, location: @harvest }
      else
        format.html { render action: 'new' }
        format.json { render json: @harvest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /harvests/1
  # PATCH/PUT /harvests/1.json
  def update
    respond_to do |format|
      if @harvest.update(harvest_params)
        format.html { redirect_to apiary_hive_path(@hive.apiary, @hive), notice: 'Harvest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @harvest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /harvests/1
  # DELETE /harvests/1.json
  def destroy
    @harvest.destroy
    h = Hive.includes(:apiary).find(params[:hive_id])
    respond_to do |format|
      format.html { redirect_to apiary_hive_path(h.apiary, h)  }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_harvest
      @harvest = Harvest.find(params[:id])
    end

    def set_hive
      @hive = Hive.includes(:apiary).find(params[:hive_id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def harvest_params
      params[:harvest][:user_id] = current_user.id
      params[:harvest][:hive_id] = params[:hive_id]
      params.require(:harvest).permit(:month,
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
                                      :user_id)
    end
end
