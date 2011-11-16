class QuestionsController < ApplicationController

  before_filter :login_required, :only => [:edit, :update]
  before_filter :validate_question, :only => [:create, :update]

  def index
    @questions = Question.paginate(params[:page] || 1)
    @youareat = "questions"
  end

  def unanswered
    @questions = Question.unanswered(params[:page] || 1)
    @youareat = "unanswered"
  end

  def answered
    @questions = Question.answered(params[:page] || 1)
  end

  def tagged
    @tag = Tag.find_by_name(params[:tag])
    @questions = @tag.nil? ? [] : Question.tagged(@tag.name)
  end

  def search
    @questions = Question.search(params[:q], params[:page] || 1)
  end

  def show
    @question = Question.find(params[:id])
    @question.views_count += 1
    @question.save
    @answer = Answer.new
    @title = @question.title + " - " + SITE_NAME
    @meta = @question.title
    @keywords = @question.tags.map{|t|t["name"]}.join(' ')
  end

  def vote
    if !login?
      render :text => "failed:请先登录再进行投票！"
      return
    end
    @question = Question.find(params[:id])
    if @question.votes.include?(current_user.id)
      render :text => "failed:您已经投过票了！"
      return
    end
    @question.votes << current_user.id
    if params[:is_vote_up] == '1'
      @question.votes_count += 1
    elsif params[:is_vote_up] == '0'
      @question.votes_count -= 1
    end
    @question.save
    render :text => "success:" + @question.votes_count.to_s
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
    if current_user.id != @question.user_id
      logger.error "Wrong operation: edit question #{@question.id} with user #{current_user.id}"
      render 'welcome/422'
    end
  end

  def create
    @question = Question.new
    @question.title = params[:question][:title].strip
    @question.content = params[:question][:content]
    if @errors.empty?
      if !login?
        log_in(@user)
      end
      @question.user = @user
      @question.save_tags(params[:tags])
      @question.save
      key = current_user.id.to_s + "_sina_api_token"
      if API_TOKENS[key]
        API_TOKENS[key].post("/statuses/update.xml", :status=>@question.title + " " + question_url(@question))
      end
      redirect_to @question
    else
      @question.tags = params[:tags]
      render :action => "new"
    end
  end

  def update
    @question = Question.find(params[:id])
    raise "Wrong operation: update question #{@question.id} with user #{current_user.id}" if current_user.id != @question.user_id
    @question.title = params[:question][:title].strip
    @question.content = params[:question][:content]
    if @errors.empty?
      @question.save_tags(params[:tags])
      @question.save
      redirect_to @question
    else
      @question.tags = params[:tags]
      render :action => "edit"
    end
  end

  private

    def validate_question
      params[:tags].gsub!("请使用空格或逗号分隔多个标签", "")
      params[:tags].strip!
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