class UsersController < ApplicationController

  def index
    @youareat = "users"
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