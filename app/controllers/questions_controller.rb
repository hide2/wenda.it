class QuestionsController < ApplicationController
  
  def index
    @questions = Question.paginate(params[:page] || 1)
    @youareat = "questions"
  end
  
  def unanswered
    @questions = Question.unanswered(params[:page] || 1)
     @youareat = "unanswered"
  end

  def show
    @question = Question.find(params[:id])
    @youareat = "questions"
  end
  
  def new
    @question = Question.new
    @youareat = "new_question"
  end
  
  def edit
    @quesiton = Question.find(params[:id])
    @youareat = "new_question"
  end
  
  def create
    @question = Question.new(params[:question])
    if @question.save
      redirect_to(@quesiton, :notice => '问题已经发布成功！')
    else
      render :action => "new"
    end
  end
  
  def update
    @question = Quesiton.find(params[:id])
    if @question.update_attributes(params[:question])
      redirect_to(@question, :notice => '问题已经成功更新！')
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    redirect_to(questions_url)
  end
  
end