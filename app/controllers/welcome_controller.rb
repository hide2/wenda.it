class WelcomeController < ApplicationController

  def index
    @questions = Question.hot
  end

end