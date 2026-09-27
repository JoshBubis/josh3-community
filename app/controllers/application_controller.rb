class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_user
    return if current_user

    redirect_to login_path, alert: "Log in to continue."
  end

  def require_admin
    require_user
    return if performed?
    return if current_user.admin?

    redirect_to root_path, alert: "That page is for moderators."
  end
end
