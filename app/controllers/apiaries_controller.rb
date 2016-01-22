class ApiariesController < ApplicationController
  before_action :authenticate
  before_action :set_apiary, only: [:show, :update, :destroy]

  def index
    @apiaries = Apiary.for_user(@user)
  end

  def show
    authorize(@apiary)
  end

  def create
    @apiary = Apiary.new(apiary_params)

    if @apiary.save
      @beekeeper = Beekeeper.create(apiary: @apiary, user: @user, role: Beekeeper::Roles::Admin)
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
    @apiary = Apiary.includes(:hives).find(params[:id])
    authorize(@apiary)
  end

  def apiary_params
    params.require(:apiary).permit(
      :name,
      :postal_code,
      :city,
      :region,
      :street_address,
      :country
    )
  end

  def pundit_user
    @beekeeper = Beekeeper.where(user_id: @user.id, apiary_id: params[:id]).take
  end
end
