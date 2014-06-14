class ApiariesController < ApplicationController
	before_action :authenticate_user!
	before_action do |c|
		action = action_name.to_sym
		unless action == :new || action == :create
			c.verify_beekeeper(params[:id], get_permission_for_action)
		end
	end

	# GET /apiaries
  # GET /apiaries.json
  def index
  	@apiaries = Apiary.joins(:beekeepers)
											.joins('LEFT JOIN `hives` ON `hives`.`apiary_id` = `apiaries`.`id`')
											.select('apiaries.*, COUNT(hives.id) AS hive_count')
											.where('beekeepers.user_id = ?', current_user.id)
											.group('apiaries.id')
  end

  # GET /apiaries/1
  # GET /apiaries/1.json
  def show
  	@apiary = Apiary.find(params[:id])
  	@beekeepers = Beekeeper.for_apiary(params[:id])
  	@hives = Hive.where(apiary_id: params[:id])
  end

  # GET /apiaries/new
  def new
    @apiary = Apiary.new
  end

  # GET /apiaries/1/edit
  def edit
		permission = Beekeeper.permission_for(current_user.id, params[:id])
		@beekeeper = Beekeeper.new
		@beekeepers = Beekeeper.for_apiary(params[:id])
		@apiary = Apiary.find(params[:id])
		@is_admin = can_perform_action?(permission, 'Admin')
  end

  # POST /apiaries
  # POST /apiairies.json
  def create
  	user_id = current_user.id
  	params[:apiary][:user_id] = user_id
    @apiary = Apiary.new(apiary_params)

    respond_to do |format|
      if @apiary.save
      	Beekeeper.create(apiary_id: @apiary.id,
												 user_id: user_id,
												 permission: "Admin",
												 creator: user_id)
        format.html { redirect_to @apiary, notice: 'Apiary was successfully created.' }
        format.json { render action: 'show', status: :created, location: @apiary }
      else
        format.html { render action: 'new' }
        format.json { render json: @apiary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apiaries/1
  # PATCH/PUT /apiaries/1.json
  def update
		@apiary = Apiary.find(params[:id])
		respond_to do |format|
			if @apiary.update(apiary_params)
				format.html { redirect_to @apiary, notice: 'Report was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: 'edit' }
				format.json { render json: @apiary.errors, status: :unprocessable_entity }
			end
		end
  end

  # DELETE /apiaries/1
  # DELETE /apiaries/1.json
  def destroy
  	@apiary = Apiary.find(params[:id])
		@apiary.destroy
		respond_to do |format|
			format.html { redirect_to apiaries_url }
			format.json { render json: {url => root_url }, status: :ok }
  	end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def apiary_params
      params.require(:apiary).permit(:name, :zip_code, :photo_url, :user_id, :city, :state, :street_address)
    end
end
