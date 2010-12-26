class WelcomeController < ApplicationController
  
  def index
    @questions = Question.hot
    @recent_tags = Tag.recent
    @recent_users = User.recent
  end

end