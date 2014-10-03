class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # If a Devise controller is being called, additional arguments may
  # be being passed to models.
  before_filter :configure_devise_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_devise_parameters
    devise_parameter_sanitizer.for(:sign_up) do |user|
      user.permit(:first_name,
                  :last_name,
                  :email,
                  :password,
                  :password_confirmation,
                  :time_zone)
    end

    devise_parameter_sanitizer.for(:account_update) do |user|
      user.permit(:first_name,
                  :last_name,
                  :email,
                  :password,
                  :password_confirmation,
                  :current_password,
                  :time_zone)
    end
  end # end configure_permitted_parameters

  def user_not_authorized
    error_message = 'You are not authorized to perform this action.'
    respond_to do |format|
      format.html { redirect_to(request.referrer || root_path, flash: { error: error_message}) }
      format.json { render json: { error: error_message }, status: :unauthorized }
    end
  end

  # Runs a block in a specific time zone. Mainly used in around_filters
  # when times need to be displayed in a specified time zone. Doing this
  # prevents the time zone from being changed on the thread used for a
  # request.
  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
