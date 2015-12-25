class UsersController < ApplicationController
  respond_to :json

  before_action :authenticate, only: [:show, :update, :destroy]
  before_action :set_and_authorize_user, except: [:create, :activate]

  def show
  end

  def create
    @requested_user = User.new(create_user_params)

    if @requested_user.save
      render action: 'show', status: :created
    else
      render json: { errors: @requested_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @requested_user.update(update_user_params)
			render action: 'show', status: :ok
		else
			render json: { errors: @requested_user.errors }, status: :unprocessable_entity
		end
  end

  def destroy
    @requested_user.destroy
		render json: { head: :no_content }
  end

  def activate
    @requested_user = User.load_from_activation_token(params[:activation_token])

    if @requested_user.present?
      @requested_user.activate!
      render json: { head: :no_content }, status: :ok
    else
      render json: { head: :no_content }, status: :bad_request
    end
  end

  private

  def set_and_authorize_user
    @requested_user = User.find(params[:id])
    authorize(@requested_user)
  end

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :timezone, :first_name, :last_name)
  end

  def update_user_params
    create_user_params
  end

  def pundit_user
    @user
  end
end
