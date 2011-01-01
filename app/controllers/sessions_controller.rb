class SessionsController < ApplicationController
  
  def create
      open_id_authentication
  end

  protected
    def open_id_authentication
      authenticate_with_open_id do |result, identity_url|
        if result.successful?
          if @current_user = @account.users.find_by_identity_url(identity_url)
            successful_login
          else
            failed_login "Sorry, no user by that identity URL exists (#{identity_url})"
          end
        else
          failed_login result.message
        end
      end
    end

  private
    def successful_login
      session[:user_id] = @current_user.id
      redirect_to(root_url)
    end

    def failed_login(message)
      flash[:error] = message
      redirect_to(new_session_url)
    end
  
end