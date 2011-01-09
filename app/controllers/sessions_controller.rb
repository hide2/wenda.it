class SessionsController < ApplicationController
  
  def new
    flash[:returnurl] = params[:returnurl] if params[:returnurl]
    if params[:login_with] == 'google'
      login_with_google
    elsif params[:login_with] == 'sina'
      login_with_sina
    elsif params[:login_with] == 'douban'
      login_with_douban
    else
      render 'welcome/404'
    end
  end
  
  def google_login
    if openid = request.env[Rack::OpenID::RESPONSE]
      case openid.status
      when :success
        ax = OpenID::AX::FetchResponse.from_success_response(openid)
        email = ax.get_single('http://axschema.org/contact/email')
        user = User.where(:email => email).first || User.new
        user.name = email.gsub('gmail.com', 'google') if user.name.nil?
        user.email = email
        log_in(user)
        redirect_to(flash[:returnurl] || root_path)
      when :failure
        render :action => 'problem'
      end
    else
      redirect_to '/login'
    end
  end
  
  def sina_login
    @oauth_verifier = params[:oauth_verifier]
    @access_token = flash[:request_token].get_access_token(:oauth_verifier => @oauth_verifier)
    sina_id = ''
    doc = REXML::Document.new(@access_token.get("/account/verify_credentials.xml").body)
    doc.elements.each('user/name') do |e|
      sina_id = e.text + "@sina"
    end
    user = User.where(:identify_id => sina_id).first || User.new
    user.name = sina_id if user.name.nil?
    user.identify_id = sina_id
    log_in(user)
    redirect_to(flash[:returnurl] || root_path)
  end
  
  def douban_login
    @access_token = flash[:request_token].get_access_token
    @access_token = OAuth::AccessToken.new(
      OAuth::Consumer.new(
        DOUBAN_API_KEY,
        DOUBAN_API_KEY_SECRET,
        {
          :site=>"http://api.douban.com",
          :scheme=>:header,
          :signature_method=>"HMAC-SHA1",
          :realm=>"http://#{SITE_NAME}"
        }
      ),
      @access_token.token,
      @access_token.secret
    )
    douban_id = ''
    doc = REXML::Document.new(@access_token.get("/people/%40me").body)
    doc.elements.each('entry/title') do |e|
      douban_id = e.text + "@douban"
    end
    user = User.where(:identify_id => douban_id).first || User.new
    user.name = douban_id if user.name.nil?
    user.identify_id = douban_id
    log_in(user)
    redirect_to(flash[:returnurl] || root_path)
  end
  
  private
    def login_with_google
      response.headers['WWW-Authenticate'] = Rack::OpenID.build_header(
          :identifier => "https://www.google.com/accounts/o8/id",
          :required => ["http://axschema.org/contact/email"],
          :return_to => google_login_sessions_url,
          :method => 'POST')
      head 401
    end
  
    def login_with_sina
      @consumer = OAuth::Consumer.new(
        SINA_API_KEY, 
        SINA_API_KEY_SECRET, 
        { 
          :site=>"http://api.t.sina.com.cn",
        }
      )
      @request_token = @consumer.get_request_token
      flash[:request_token] = @request_token
      redirect_to @request_token.authorize_url + "&oauth_callback=#{sina_login_sessions_url}"
    end
  
    def login_with_douban
      @consumer = OAuth::Consumer.new(
        DOUBAN_API_KEY, 
        DOUBAN_API_KEY_SECRET, 
        { 
          :site=>"http://www.douban.com",
          :request_token_path=>"/service/auth/request_token",
          :access_token_path=>"/service/auth/access_token",
          :authorize_path=>"/service/auth/authorize",
          :signature_method=>"HMAC-SHA1",
          :scheme=>:header,
          :realm=>"http://#{SITE_NAME}"
        }
      )
      @request_token = @consumer.get_request_token
      flash[:request_token] = @request_token
      redirect_to @request_token.authorize_url + "&oauth_callback=#{douban_login_sessions_url}"
    end
  
end