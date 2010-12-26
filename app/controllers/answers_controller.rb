class AnswersController < ApplicationController

  before_filter :validate_answer, :only => [:create, :update]
  
  def create
    @question = Question.find(params[:answer][:question_id])
    @answer = Answer.new
    @answer.content = params[:answer][:content]
    @answer.question_id = params[:answer][:question_id]
    if @errors.empty?
      if !login?
        @user.save
        session[:user_id] = @user.id
      end
      @answer.user = @user
      @answer.save
      @question.answers_count += 1
      @question.save
      redirect_to @question
    else
      flash[:errors] = @errors
      flash[:_content] = @answer.content
      flash[:_username] = @user.name
      flash[:_email] = @user.email
      redirect_to @question
    end
  end
  
  def vote
    @answer = Answer.find(params[:id])
    if params[:delta] == 'up'
      @answer.votes_count += 1
    elsif params[:delta] == 'down'
      @answer.votes_count -= 1
    end
    @answer.save
    render :text => @answer.votes_count
  end
  
  private
  
    def validate_answer
      @errors = []
      if params[:answer][:content].blank?
        @errors << "答案不能为空"
      end
      if login?
        @user = login_user
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