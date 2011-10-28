class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :login?, :current_user

  def login?
    !session[:user_id].nil?
  end

  def current_user
    @current_user ||= User.find session[:user_id]
  end

  def log_in(user)
    user.last_login_time = Time.now
    user.last_login_ip = request.remote_ip
    user.save
    session[:user_id] = user.id
  end

  private

    def login_required
      unless login?
        redirect_to "/login?returnurl=#{request.path}"
      end
    end

end
