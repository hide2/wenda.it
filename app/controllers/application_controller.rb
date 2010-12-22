class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :login?, :login_user
    
  def login?
    session[:user_id]
  end
  
  def login_user
    User.find session[:user_id]
  end
  
end
