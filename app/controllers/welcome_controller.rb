class WelcomeController < ApplicationController
  
  def index
    @questions = Question.latest
  end
end