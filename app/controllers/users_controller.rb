class UsersController < ApplicationController

  def index
    @users = User.paginate(params[:page] || 1)
    @youareat = "users"
  end

  def search
    @users = User.search(params[:keyword])
    render :layout => false
  end

  def show
    @user = User.find params[:id]
    @user.views_count += 1
    @user.save
  end

  def signup
    if login? && current_user.crypted_password.nil?
      @user = current_user
    elsif !login?
      @user = User.new
    else
      raise "请先退出系统！"
    end
    @prev_action = "signup"
  end

  def edit
    @user = current_user
    @prev_action = "edit"
  end

  def create
    validate_new_user
    if @errors.empty?
        @user.password = params[:password].strip
        log_in(@user)
        @user.save_avatar(params[:image]) if params[:image]
        redirect_to root_path
    else
      render :action => "signup"
    end
  end

  def update
    validate_update_user
    if @errors.empty?
        @user.about_me = params[:about_me]
        @user.password = params[:password].strip if !params[:password].blank?
        @user.save
        @user.save_avatar(params[:image]) if params[:image]
        session[:user_id] = @user.id
        redirect_to @user
    else
      @prev_action = params[:prev_action]
      render :action => @prev_action
    end
  end

  def login
    if request.post?
      validate_login
      if @errors.empty?
        log_in(@user)
        redirect_to params[:returnurl] || root_path
      else
        flash[:_username] = params[:username]
        render :action => "login"
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path
  end

  private

    def validate_new_user
      @errors = []
      @user = User.new
      @user.name = params[:username].strip
      @user.email = params[:email].strip
      if @user.name.blank?
        @errors << "用户名不能为空"
      end
      if User.find_by_name(@user.name) || User.find_by_email(@user.name)
        @errors << "该用户名已经被占用"
      end
      if params[:password].blank?
        @errors << "密码不能为空"
      end
      if params[:password] != params[:password_confirm]
        @errors << "两次输入的密码不一致"
      end
      if @user.email.blank?
        @errors << "Email不能为空"
      elsif !(/^[a-zA-Z0-9_\.]+@[a-zA-Z0-9-]+[\.a-zA-Z]+$/ =~ @user.email)
        @errors << "Email格式不正确"
      end
      if User.find_by_email(@user.email)
        @errors << "该Email已经被占用"
      end
    end

    def validate_update_user
      @errors = []
      @user = current_user
      @user.name = params[:username].strip
      @user.email = params[:email].strip
      if @user.name.blank?
        @errors << "用户名不能为空"
      end
      if User.find_by_name(@user.name) && User.find_by_name(@user.name).id != @user.id
        @errors << "该用户名已经被占用"
      end
      if params[:prev_action] == 'signup'
        if params[:password].blank?
          @errors << "密码不能为空"
        end
        if params[:password] != params[:password_confirm]
          @errors << "两次输入的密码不一致"
        end
      else
        if !params[:password].blank? && params[:password] != params[:password_confirm]
          @errors << "两次输入的密码不一致"
        end
      end
      if @user.email.blank?
        @errors << "Email不能为空"
      elsif !(/^[a-zA-Z0-9_\.]+@[a-zA-Z0-9-]+[\.a-zA-Z]+$/ =~ @user.email)
        @errors << "Email格式不正确"
      end
      if User.find_by_email(@user.email) && User.find_by_email(@user.email).id != @user.id
        @errors << "该Email已经被占用"
      end
    end

    def validate_login
      @errors = []
      if params[:username].blank?
        @errors << "用户名/Email不能为空"
      end
      if params[:password].blank?
        @errors << "密码不能为空"
      end
      if !params[:username].blank? && !params[:password].blank?
        @user = User.find_by_name(params[:username]) || User.find_by_email(params[:username])
        if @user.nil?
          @errors << "用户名/Email不存在"
        else
          @user = User.authenticate(@user.name, params[:password])
          if @user.nil?
            @errors << "密码不正确"
          end
        end
      end
    end

end