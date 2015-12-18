class ApiariesController < ApplicationController
  respond_to :json

  before_action :authenticate
  before_action :set_apiary, only: [:update, :destroy]

  def index
    @apiaries = Apiary.for_user(@user)
  end

  def show
    @apiary = Apiary.includes(:hives).find(params[:id])
    authorize(@apiary)
  end

  def create
    @apiary = Apiary.new(apiary_params)

    if @apiary.save
      Beekeeper.create(apiary: @apiary, user: @user, permission: 'Admin')
      render action: 'show', status: :created, location: @apiary
    else
      render json: @apiary.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @apiary.update(apiary_params)
      render action: 'show', status: :created, location: @apiary
    else
      render json: @apiary.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @apiary.destroy
    render json: { head: :no_content }
  end

  private

  def set_apiary
    @apiary = Apiary.find(params[:id])
    authorize(@apiary)
  end

  def apiary_params
    params.require(:apiary).permit(
      :name,
      :zip_code,
      :city,
      :state,
      :street_address
    )
  end

  def pundit_user
    @beekeeper = Beekeeper.where(user_id: @user.id, apiary_id: params[:id]).take
  end
end
