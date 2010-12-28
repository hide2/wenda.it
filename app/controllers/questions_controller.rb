class QuestionsController < ApplicationController

  before_filter :validate_question, :only => [:create, :update]
  
  def index
    @questions = Question.paginate(params[:page] || 1)
    @recent_tags = Tag.recent
    @recent_users = User.recent
    @youareat = "questions"
  end
  
  def unanswered
    @questions = Question.unanswered(params[:page] || 1)
    @recent_tags = Tag.recent
    @recent_users = User.recent
    @youareat = "unanswered"
  end
  
  def tagged
    @tag = Tag.find_by_name(params[:tag])
    @questions = @tag.nil? ? [] : Question.tagged(@tag.name)
    @recent_tags = Tag.recent
    @recent_users = User.recent
    @youareat = "tags"
  end

  def show
    @question = Question.find(params[:id])
    @question.views_count += 1
    @question.save
    @answer = Answer.new
    @youareat = "questions"
  end
  
  def vote
    @question = Question.find(params[:id])
    if params[:is_vote_up] == '1'
      @question.votes_count += 1
    elsif params[:is_vote_up] == '0'
      @question.votes_count -= 1
    end
    @question.save
    render :text => @question.votes_count
  end
  
  def preview
    render :text => RDiscount.new(params[:data]).to_html
  end
  
  def new
    @question = Question.new
    @youareat = "new_question"
  end
  
  def edit
    @question = Question.find(params[:id])
    @question.content = @question.content
    @youareat = "questions"
  end
  
  def create
    @question = Question.new
    @question.title = params[:question][:title].strip
    @question.content = params[:question][:content]
    @question.tags = params[:tags].strip
    if @errors.empty?
      if !login?
        @user.last_login = Time.now
        @user.save
        session[:user_id] = @user.id
      end
      @question.user = @user
      @question.save_tags(params[:tags])
      @question.save
      redirect_to @question
    else
      render :action => "new"
    end
  end
  
  def update
    @question = Question.find(params[:id])
    @question.title = params[:question][:title].strip
    @question.content = params[:question][:content]
    @question.tags = params[:tags].strip
    if @errors.empty?
      @question.save_tags(params[:tags])
      @question.save
      redirect_to @question
    else
      @question.content = @question.content
      render :action => "edit"
    end
  end
  
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    redirect_to questions_url
  end
  
  private
  
    def validate_question
      params[:tags].gsub!("请使用空格分隔多个标签", "")
      @errors = []
      if params[:question][:title].size <= 10
        @errors << "标题不能短于10个字符"
      end
      if params[:question][:content].size <= 30
        @errors << "内容不能短于30个字符"
      end
      if params[:tags].blank?
        @errors << "至少需要一个标签"
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