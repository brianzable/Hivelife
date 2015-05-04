class UsersController < ApplicationController
  respond_to :json

  before_action :set_user, except: [:create]

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

private

  def set_user
    @user = User.find(params[:id])
  end

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def update_user_params
    create_user_params
  end
end
