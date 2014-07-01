class InspectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inspection, only: [:edit, :update, :destroy]
  before_action :set_hive, only: [:edit, :update, :create]
  around_filter :user_time_zone
  before_action do |c|
    h = Hive.find(params[:hive_id])
    c.verify_beekeeper(h.apiary_id, get_permission_for_action)
  end

  # GET /hives/{hive_id}/inspections/1
  # GET /hives/{hive_id}/inspections/1.json
  def show
    @inspection = Inspection.includes(:user).find(params[:id])
  end

  # GET /hives/{hive_id}/inspections/new
  def new
    @action = hive_inspections_url
    @method = :post
    @hive = Hive.find(params[:hive_id])
    i = Inspection.order('inspected_at').where(hive_id: params[:hive_id]).last
    if i.nil?
      @inspection = Inspection.new
    else
      @inspection = i
    end

  end

  # GET /hives/{hive_id}/inspections/1/edit
  def edit
    @action = hive_inspection_url(@hive, @inspection)
    @method = :put
  end

  # POST /hives/{hive_id}/inspections
  # POST /hives/{hive_id}/inspections.json
  def create
    @inspection = Inspection.new(inspection_params)
    respond_to do |format|
      if @inspection.save
        format.html { redirect_to apiary_hive_path(@hive.apiary, @hive), notice: 'inspection was successfully created.' }
        format.json { render action: 'show', status: :created, location: @inspection }
      else
        format.html { render action: 'new' }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hives/{hive_id}/inspections/1
  # PATCH/PUT /hives/{hive_id}/inspections/1.json
  def update
    respond_to do |format|
      if @inspection.update(inspection_params)
        format.html { redirect_to [@hive, @inspection], notice: 'inspection was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @inspection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hives/{hive_id}/inspections/1
  # DELETE /hives/{hive_id}/inspections/1.json
  def destroy
    @inspection.destroy
    respond_to do |format|
      format.html { redirect_to hive_inspections_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inspection
      @inspection = Inspection.find(params[:id])
    end

    def set_hive
      @hive = Hive.includes(:apiary).find(params[:hive_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inspection_params
      action = action_name.to_sym
      include_id = (action == :update)

      params[:inspection][:user_id] = current_user.id
      params[:inspection][:hive_id] = params[:hive_id]
			params.require(:inspection).permit(:month,
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
                                         :user_id,
                                         :hive_id,
                                         :health,
																		 		:honey_supers_attributes =>
                                             honey_super_attributes(include_id),
																		 		:brood_boxes_attributes =>
                                             brood_box_attributes(include_id),
																		 		:diseases_attributes =>
                                             disease_attributes(include_id)
                                          )
    end

    def honey_super_attributes(include_id = false)
      attrs = [:ready_for_harvest, :full, :capped, :_destroy]
      append_id(attrs, include_id)
    end

    def brood_box_attributes(include_id = false)
      attrs = [
        :pattern,
        :eggs_sighted,
        :queen_sighted,
        :queen_cells_sighted,
        :honey_sighted,
        :pollen_sighted,
        :swarm_cell_sighted,
        :supercedure_cell_sighted,
        :swarm_cells_capped,
        :_destroy
      ]
      append_id(attrs, include_id)
    end

    def disease_attributes(include_id = false)
      attrs = [:disease_type, :treatment, :_destroy]
      append_id(attrs, include_id)
    end

    def append_id(attrs, yes = false)
      if yes
        attrs.push(:id)
      else
        attrs
      end
    end
end
