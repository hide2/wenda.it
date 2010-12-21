class QuestionsController < ApplicationController

  before_filter :validate_create_question, :only => [:create, :update]
  
  def index
    @questions = Question.paginate(params[:page] || 1)
    @youareat = "questions"
  end
  
  def unanswered
    @questions = Question.unanswered(params[:page] || 1)
    @youareat = "unanswered"
  end
  
  def tagged
    @tag = Tag.find_by_name(params[:tag])
    @questions = Question.all("tags.name" => @tag.name)
    @youareat = "tags"
  end

  def show
    @question = Question.find(params[:id])
    @question.views_count += 1
    @question.save
    @youareat = "questions"
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
    @user = User.new
    @user.name = params[:username]
    @user.email = params[:email]
    @user.save
    @question = Question.new
    @question.title = params[:question][:title]
    @question.content = params[:question][:content]
    @question.user = @user
    @question.save_tags(params[:tags])
    if @question.save
      redirect_to(@question, :notice => '问题已经成功发布！')
    else
      render :action => "new"
    end
  end
  
  def update
    @question = Question.find(params[:id])
    @question.title = params[:question][:title]
    @question.content = params[:question][:content]
    @question.save_tags(params[:tags])
    if @errors.empty?
      @question.save
      redirect_to(@question, :notice => '问题已经成功更新！')
    else
      @question.content = @question.content
      render :action => "edit"
    end
  end
  
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    redirect_to(questions_url)
  end
  
  private
  
    def validate_create_question
      params[:tags].gsub!("请使用空格分隔多个标签", "")
      @errors = []
      if params[:question][:title].size <= 10
        @errors << "问题标题不能短于10个字符"
      end
      if params[:question][:content].size <= 30
        @errors << "问题内容不能短于30个字符"
      end
      if params[:tags].blank?
        @errors << "问题至少需要一个标签"
      end
    end
  
end