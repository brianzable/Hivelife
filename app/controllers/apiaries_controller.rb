class ApiariesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_apiary, only: [:show, :edit, :update, :destroy]

	# GET /
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
		authorize(@apiary)
  	@beekeepers = Beekeeper.for_apiary(params[:id])
  	@hives = Hive.where(apiary_id: params[:id])
  end

  # GET /apiaries/new
  def new
    @apiary = Apiary.new
  end

  # GET /apiaries/1/edit
  def edit
		authorize(@apiary)
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
												 permission: 'Admin',
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
		authorize(@apiary)
		respond_to do |format|
			if @apiary.update(apiary_params)
				format.html { redirect_to @apiary, notice: 'Apiary was successfully updated.' }
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
		authorize(@apiary)
		@apiary.destroy
		respond_to do |format|
			format.html { redirect_to apiaries_url }
			format.json { render json: {url => root_url }, status: :ok }
  	end
  end

  private
		def set_apiary
			@apiary = Apiary.find(params[:id])
		end

    # Never trust parameters from the scary internet, only allow the white list through.
    def apiary_params
			if params[:apiary][:beekeepers_attributes]
				beekeeper_attributes = params[:apiary][:beekeepers_attributes]
				beekeeper_attributes.each do |index, beekeeper_params|
					beekeeper_params[:user_id] = User.email_to_user_id(beekeeper_params[:email])
					beekeeper_params[:creator] = current_user.id
					beekeeper_params[:apiary_id] = params[:id]
				end
			end

      params.require(:apiary).permit(:name,
																		 :zip_code,
																		 :photo_url,
																		 :user_id,
																		 :city,
																		 :state,
																		 :street_address,
																		 :beekeepers_attributes =>
																		    [:id,
																				 :creator,
																				 :apiary_id,
																				 :user_id,
																				 :permission,
																				 :_destroy])
    end

		def pundit_user
			Beekeeper.where(user_id: current_user.id,
											apiary_id: params[:id]).first
		end
end
