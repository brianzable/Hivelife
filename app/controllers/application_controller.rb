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

  def get_permission_for_action
    action = action_name
    action_to_permission = {
      :show => 'Read',
      :edit => 'Write',
      :update => 'Write',
      :create => 'Write',
      :new => 'Write',
      :destroy => 'Admin'
    }
    action_to_permission[action.to_sym]
  end

  def verify_beekeeper(apiary_id, required_permission)
    authenticate_user!
    user_id = current_user.id

    permission = Beekeeper.permission_for(user_id, apiary_id)

    unless can_perform_action?(permission, required_permission)
      not_permitted
    end
  end

  # Determines whether or not an action can be performed.
  # Returns true if the permission satisified the required_permission,
  # false otherwise
  def can_perform_action?(permission, required_permission)
    # Admin can do anything, just return true
    if permission == 'Admin'
      return true
    # Write == Write or Read == Read, when permission matches
    elsif permission == required_permission
      return true
    # Write can do anything read can do
    elsif permission == 'Write' && required_permission == 'Read'
      return true
    end
    return false
  end

  # Redirects to the root url and creates a flash message
  # when a user does not have permission to do something
  def not_permitted
    redirect_to(root_url,
                notice: 'You do not have permission to perform this action.')
  end

  def user_not_authorized
    error_message = 'You are not authorized to perform this action.'
    respond_to do |format|
      format.html do
        redirect_to(request.referrer || root_path, flash: { error: error_message})
      end
      format.json do
        render json: { error: error_message }, status: :unauthorized
      end
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
