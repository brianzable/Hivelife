class BeekeepersController < ApplicationController
	respond_to :json

  before_action :set_beekeeper, only: [:show, :edit, :update, :destroy]

	# By default Devise performs a redirect if a user is not logged in. Send json
	# instead in this controller. If they are logged in, ensure they have the
	# proper permission's to CRUD beekeepers.
	before_filter :verify_user

  # GET /beekeepers/1.json
  def show
  	@beekeeper = Beekeeper.includes(:user).find(params[:id])
  end

  # POST /beekeepers
  # POST /beekeepers.json
  def create
    @beekeeper = Beekeeper.new(create_beekeeper_params)
    if @beekeeper.save
    	render action: 'show', status: :created, location: @hive
    else
    	html = render_to_string partial: "shared/errors", locals: {object: @beekeeper}
    	render :json => { :errors => html },
    				 :status => :unprocessable_entity
    end
  end

  # PATCH/PUT /beekeepers/1
  # PATCH/PUT /beekeepers/1.json
  def update
  	user = current_user.id
		if @beekeeper.update(update_beekeeper_params)
			render :json => {"status" => "ok"}, :status => :ok
		else
			render :json => {:errors => @beekeeper.errors.full_messages },
						 :status => :unprocessable_entity
		end
  end

  # DELETE /beekeepers/1
  # DELETE /beekeepers/1.json
  def destroy
  	@beekeeper = Beekeeper.find(params[:id])
		@beekeeper.destroy
    render :json => {"status" => "ok"}, :status => :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_beekeeper
      @beekeeper = Beekeeper.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def create_beekeeper_params
    	user = current_user.id
  		params[:beekeeper][:user_id] = User.email_to_user_id(params[:beekeeper][:email])
  		params[:beekeeper][:creator] = user
      params.require(:beekeeper).permit(:apiary_id, :user_id, :permission, :email, :creator)
    end

    def update_beekeeper_params
    	params.require(:beekeeper).permit(:permission, :apiary_id)
    end

		def verify_user
			user_verified = false
			apiary_id = params[:beekeeper][:apiary_id]
			if user_signed_in?
				permission = Beekeeper.permission_for(current_user.id, apiary_id)
				if can_perform_action?(permission, 'Admin')
					user_verified = true
				end
			end

			unless user_verified
				render :json => {"error" => "You are not authorized to perform this action."},
							 :status => :unprocessable_entity
			end
		end

end
