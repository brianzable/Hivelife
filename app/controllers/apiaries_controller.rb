class ApiariesController < ApplicationController
  before_action :require_login
  before_action :set_apiary, only: [:show, :edit, :update, :destroy]

  def index
    @apiaries = Apiary.for_user(current_user)
  end

  def show
    @apiary = Apiary.includes(:hives).find(params[:id])
    authorize(@apiary)

    @beekeepers = Beekeeper.for_apiary(params[:id])
  end

  def new
    @apiary = Apiary.new
  end

  def edit
  end

  def create
    @apiary = Apiary.new(apiary_params)
    respond_to do |format|
      if @apiary.save
        Beekeeper.create(
          apiary_id: @apiary.id,
          user_id: current_user.id,
          permission: 'Admin'
        )
        format.html { redirect_to @apiary, notice: 'Apiary was successfully created.' }
        format.json { render action: 'show', status: :created, location: @apiary }
      else
        format.html { render action: 'new' }
        format.json { render json: @apiary.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @apiary.update(apiary_params)
        format.html { redirect_to @apiary, notice: 'Apiary was successfully updated.' }
        format.json { render action: 'show', status: :created, location: @apiary }
      else
        format.html { render action: 'edit' }
        format.json { render json: @apiary.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @apiary.destroy
    respond_to do |format|
      format.html { redirect_to apiaries_url }
      format.json { render json: { head: :no_content } }
    end
  end

private
  def set_apiary
    @apiary = Apiary.find(params[:id])
    authorize(@apiary)
  end

  def apiary_params
    if params[:apiary][:beekeepers_attributes]
      beekeeper_attributes = params[:apiary][:beekeepers_attributes]
      beekeeper_attributes.each do |index, beekeeper_params|
        beekeeper_params[:user_id] = User.email_to_user_id(beekeeper_params[:email])
        beekeeper_params[:apiary_id] = params[:id]
      end
    end

    params.require(:apiary).permit(
      :name,
      :zip_code,
      :photo_url,
      :city,
      :state,
      :street_address,
      :beekeepers_attributes => [
        :id,
        :apiary_id,
        :user_id,
        :permission,
        :_destroy
      ]
    )
  end

  def pundit_user
    Beekeeper.where(
      user_id: current_user.id,
      apiary_id: params[:id]
    ).take
  end
end
