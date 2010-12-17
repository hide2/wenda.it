class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_charset
  before_filter :configure_charsets
  
  def set_charset
    headers["Content-Type"] = "text/html; charset=utf-8"
  end

  def configure_charsets
    response.headers["Content-Type"] = "text/html; charset=utf-8"
  end
end
