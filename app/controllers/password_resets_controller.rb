class PasswordResetsController < ApplicationController
  def create
    @requested_user = User.find_by_email(params[:email])

    @requested_user.deliver_reset_password_instructions! if @requested_user.present?

    render json: { head: :no_content }, status: :created
  end

  def update
    requested_user = User.load_from_reset_password_token(params[:id])

    if requested_user.blank?
      raise Pundit::NotAuthorizedError
    end

    requested_user.password_confirmation = params[:user][:password_confirmation]
    if requested_user.change_password!(params[:user][:password])
      render json: { head: :no_content }, status: :ok
    else
      render json: requested_user.errors.full_messages, status: :unprocessable_entity
    end
  end
end
