class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :null_session

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

protected

  def authenticate
    authenticate_with_token || render_unauthorized
  end

  def authenticate_with_token
    authenticate_or_request_with_http_token do |token, options|
      User.find_by(authentication_token: token)
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: 'You are not authorized to perform this action', status: 401
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
