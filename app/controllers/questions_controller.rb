class QuestionsController < ApplicationController
  
  def index
    @questions = Question.latest
  end
  
end