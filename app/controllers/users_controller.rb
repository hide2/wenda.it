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
  end
  
  def edit
    @user = User.find params[:id]
    raise "Wrong user!" if !login? || @user.id != login_user.id
  end
  
  def update
    u = login_user
    u.password = params[:password]
    u.save!
    flash[:notice] = "密码更改成功！"
    redirect_to edit_user_path(u)
  end
  
end