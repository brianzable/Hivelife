class BeekeepersController < ApplicationController
  respond_to :json

  before_action :authenticate
  before_action :set_and_authorize_beekeeper, only: [:show, :update, :destroy]

  def index
    @beekeepers = Beekeeper.where(apiary_id: params[:apiary_id])
  end

  def show
  end

  def create
    @beekeeper = Beekeeper.new(create_beekeeper_params)
    authorize @beekeeper

    if @beekeeper.save
      render action: 'show', status: :created
    else
      render json: { errors: @beekeeper.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @beekeeper.update(update_beekeeper_params)
      render action: 'show', status: :ok
    else
      render json: { errors: @beekeeper.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @beekeeper.destroy
    render json: { head: :no_content }
  end

private

  def set_and_authorize_beekeeper
    @beekeeper = Beekeeper.includes(:user).where(
      id: params[:id],
      apiary_id: params[:apiary_id]
    ).take
    authorize @beekeeper
  end

  def create_beekeeper_params
    params[:beekeeper][:user_id] = User.where(email: params[:beekeeper][:email]).take.id
    params[:beekeeper][:apiary_id] = params[:apiary_id]
    params.require(:beekeeper).permit(:apiary_id, :user_id, :permission, :email, :creator)
  end

  def update_beekeeper_params
    params.require(:beekeeper).permit(:permission, :apiary_id)
  end

  def pundit_user
    Beekeeper.where(user_id: @user.id, apiary_id: params[:apiary_id]).first
  end
end
