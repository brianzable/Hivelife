class ApplicationController < ActionController::Base
  include Pundit

  respond_to :json

  protect_from_forgery with: :null_session

  rescue_from Pundit::NotAuthorizedError, with: :render_not_found

  protected

  def authenticate
    authenticate_with_token || render_unauthorized
  end

  def authenticate_with_token
    authenticate_or_request_with_http_token do |token, options|
      @user = User.find_by(authentication_token: token)
      if @user.blank?
        render_unauthorized
      else
        @user
      end
    end
  end

  def render_not_found
    headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: { error: 'The requested resource could not be found.' }, status: :not_found
  end

  def render_unauthorized
    headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: { error: 'You are not authorized to perform this action.' }, status: :unauthorized
  end

  def set_time_zone(&block)
    Time.use_zone(@user.timezone, &block)
  end
end
