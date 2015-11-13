class UsersController < ApplicationController
  respond_to :json

  before_action :require_login, only: [:update, :destroy]
  before_action :set_and_authorize_user, except: [:create, :activate]

  def show
  end

  def create
    @user = User.new(create_user_params)

    if @user.save
      render action: 'show', status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(update_user_params)
			render action: 'show', status: :ok
		else
			render json: { errors: @user.errors }, status: :unprocessable_entity
		end
  end

  def destroy
    @user.destroy
		render json: { head: :no_content }
  end

  def activate
    @user = User.load_from_activation_token(params[:activation_token])
    if @user
      @user.activate!
      render json: { head: :no_content }, status: :ok
    else
      render json: { head: :no_content }, status: :bad_request
    end
  end

  private

  def set_and_authorize_user
    @user = User.find(params[:id])
    authorize(@user)
  end

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def update_user_params
    create_user_params
  end

  def pundit_user
    current_user
  end
end
