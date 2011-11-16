class CommentsController < ApplicationController

  before_filter :validate_comment, :only => [:create]

  def new
    @answer = Answer.find(params[:answer_id])
    @comment = Comment.new
  end

  def create
    @answer = Answer.find(params[:comment][:answer_id])
    @comment = Comment.new
    @comment.content = params[:comment][:content]
    @comment.answer_id = @answer.id
    if @errors.empty?
      if !login?
        log_in(@user)
      end
      @comment.user = @user
      @comment.save
      redirect_to "/questions/#{@answer.question_id}" + "#" + "#{@comment.id}"
    else
      flash[:_username] = @user.name
      flash[:_email] = @user.email
      render :action => "new"
    end
  end

  private

    def validate_comment
      @errors = []
      if params[:comment][:content].blank?
        @errors << "评论不能为空"
      end
      if login?
        @user = current_user
      else
        @user = User.new
        @user.name = params[:username].strip
        @user.email = params[:email].strip
        if @user.name.blank?
          @errors << "用户名不能为空"
        end
        if User.find_by_name(@user.name)
          @errors << "该用户名已经被占用"
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
    end

end