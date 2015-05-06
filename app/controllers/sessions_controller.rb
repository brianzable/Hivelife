class SessionsController < ApplicationController
  respond_to :json

  def sign_in
    @user = login(params[:email], params[:password])

    unless @user
      render json: { error: 'Invalid credentials' }, status: :unprocessable_entity
    end
  end
end
