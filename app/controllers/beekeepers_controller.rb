class BeekeepersController < ApplicationController
	respond_to :json

	before_action :set_and_authorize_beekeeper, only: [:show, :update, :destroy]

  # GET apiaries/{apiary_id}/beekeepers/1.json
  def show
  end

  # POST /apiaries/{apiary_id}/beekeepers
  # POST /apiaries/{apiary_id}/beekeepers.json
  def create
		@beekeeper = Beekeeper.new(create_beekeeper_params)

		authorize @beekeeper

    if @beekeeper.save
    	render action: 'show', status: :created
    else
			render json: { errors: @beekeeper.errors.full_messages },
						 status: :unprocessable_entity
    end
  end

  # PATCH/PUT /apiaries/{apiary_id}/beekeepers/1
  # PATCH/PUT /apiaries/{apiary_id}/beekeepers/1.json
  def update
		authorize @beekeeper

    if @beekeeper.update(update_beekeeper_params)
			render action: 'show', status: :ok
		else
			render json: { errors: @beekeeper.errors.full_messages },
						status: :unprocessable_entity
		end
  end

  # DELETE /apiaries/{apiary_id}/beekeepers/1
  # DELETE /apiaries/{apiary_id}/beekeepers/1.json
  def destroy
		@beekeeper.destroy
		render json: { head: :no_content }
  end

  # POST /apiaries/{apiary_id}/beekeepers/new/preview
	def preview
		@beekeeper = Beekeeper.new(create_beekeeper_params)
		if @beekeeper.valid?
			render action: 'show', status: :ok
		else
			render json: { errors: @beekeeper.errors.full_messages },
						status: :unprocessable_entity
		end
	end

private
  def set_and_authorize_beekeeper
    @beekeeper = Beekeeper.includes(:user).find(params[:id])
		authorize @beekeeper
  end

  def create_beekeeper_params
    params[:beekeeper][:user_id] = User.email_to_user_id(params[:beekeeper][:email])
    params[:beekeeper][:creator] = current_user.id
		params[:beekeeper][:apiary_id] = params[:apiary_id]
    params.require(:beekeeper).permit(:apiary_id, :user_id, :permission, :email, :creator)
  end

  def update_beekeeper_params
  	params.require(:beekeeper).permit(:permission, :apiary_id)
  end

	def pundit_user
		Beekeeper.where(user_id: current_user.id, apiary_id: params[:apiary_id]).first
	end
end
