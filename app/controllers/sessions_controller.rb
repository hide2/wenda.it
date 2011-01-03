class SessionsController < ApplicationController
  
  def new
    flash[:returnurl] = params[:returnurl] if params[:returnurl]
    response.headers['WWW-Authenticate'] = Rack::OpenID.build_header(
        :identifier => "https://www.google.com/accounts/o8/id",
        :required => ["http://axschema.org/contact/email"],
        :return_to => sessions_url,
        :method => 'POST')
    head 401
  end
  
  def create
    if openid = request.env[Rack::OpenID::RESPONSE]
      case openid.status
      when :success
        ax = OpenID::AX::FetchResponse.from_success_response(openid)
        identify_url = openid.display_identifier
        email = ax.get_single('http://axschema.org/contact/email')
        user = User.where(:email => email).first || User.new
        user.email = email
        user.identify_url = identify_url
        log_in(user)
        redirect_to(flash[:returnurl] || root_path)
      when :failure
        render :action => 'problem'
      end
    else
      redirect_to new_session_path
    end
  end
  
end